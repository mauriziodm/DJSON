{***************************************************************************}
{                                                                           }
{           DJSON - (Delphi JSON library)                                    }
{                                                                           }
{           Copyright (C) 2016 Maurizio Del Magno                           }
{                                                                           }
{           mauriziodm@levantesw.it                                         }
{           mauriziodelmagno@gmail.com                                      }
{           https://github.com/mauriziodm/DSON.git                          }
{                                                                           }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  This project is based off of the ObjectsMappers unit included with the   }
{  Delphi MVC Framework project by Daniele Teti and the DMVCFramework Team. }
{                                                                           }
{***************************************************************************}



unit DJSON.Duck.Dictionary;

interface

uses
  System.Rtti, DJSON.Duck.Interfaces;

type

  TdjDuckDictionaryEnumerator = class
  strict private
    FObjectAsDuck: TObject;
    FMoveNextMethod: TRttiMethod;
    FCurrentProperty: TRttiProperty;
  public
    constructor Create(AObjectAsDuck: TObject);
    destructor Destroy; override;
    function Current: TValue;
    function MoveNext: Boolean;
  end;

  TdjDuckDictionary = class(TInterfacedObject, IdjDuckDictionary)
  strict private
    FObjAsDuck: TObject;
    FAddMethod: TRttiMethod;
    FKeysProperty: TRttiProperty;
    FValuesProperty: TRttiProperty;
    FCountProperty: TRttiProperty;
    FKeysEnumerator: TdjDuckDictionaryEnumerator;
    FValuesEnumerator: TdjDuckDictionaryEnumerator;
  public
    class function TryCreate(const AObjAsDuck:TObject): IdjDuckDictionary;
    constructor Create(AObjAsDuck:TObject; const AKeysProperty,AValuesProperty,ACountProperty:TRTTIProperty;
      const AAddMethod:TRTTIMethod; const AKeysEnumerator,AValuesEnumerator:TdjDuckDictionaryEnumerator);
    destructor Destroy; override;
    procedure Add(const AKey, AValue: TValue);
    function GetCurrentKey: TValue;
    function GetCurrentValue: TValue;
    function MoveNext: Boolean;
    function Count: Integer;
  end;

implementation

uses
  DJSON.Utils.RTTI, DJSON.Exceptions;

{ TdjDuckDictionary }

procedure TdjDuckDictionary.Add(const AKey, AValue: TValue);
begin
  FAddMethod.Invoke(FObjAsDuck, [AKey, AValue]);
end;

function TdjDuckDictionary.Count: Integer;
begin
  Result := FCountProperty.GetValue(FObjAsDuck).AsInteger;
end;

constructor TdjDuckDictionary.Create(AObjAsDuck:TObject; const AKeysProperty,AValuesProperty,ACountProperty:TRTTIProperty;
  const AAddMethod:TRTTIMethod; const AKeysEnumerator,AValuesEnumerator:TdjDuckDictionaryEnumerator);
begin
  inherited Create;
  FObjAsDuck := AObjAsDuck;
  FKeysProperty := AKeysProperty;
  FValuesProperty := AValuesProperty;
  FCountProperty := ACountProperty;
  FAddMethod := AAddMethod;
  FKeysEnumerator := AKeysEnumerator;
  FValuesEnumerator := AValuesEnumerator;
end;

destructor TdjDuckDictionary.Destroy;
begin
  if assigned(FKeysEnumerator) then
    FKeysEnumerator.Free;
  if assigned(FValuesEnumerator) then
    FValuesEnumerator.Free;
  inherited;
end;

function TdjDuckDictionary.GetCurrentKey: TValue;
begin
  Result := FKeysEnumerator.Current;
end;

function TdjDuckDictionary.GetCurrentValue: TValue;
begin
  Result := FValuesEnumerator.Current;
end;

function TdjDuckDictionary.MoveNext: Boolean;
begin
  Result := (FKeysEnumerator.MoveNext and FValuesEnumerator.MoveNext);
end;

class function TdjDuckDictionary.TryCreate(const AObjAsDuck: TObject): IdjDuckDictionary;
var
  LType: TRttiType;
  LKeysProperty: TRttiProperty;
  LValuesProperty: TRttiProperty;
  LCountProperty: TRttiProperty;
  LAddMethod: TRttiMethod;
  LKeysEnumerator: TdjDuckDictionaryEnumerator;
  LValuesEnumerator: TdjDuckDictionaryEnumerator;
  LObj: TObject;
begin
  // Check received object
  if not Assigned(AObjAsDuck) then Exit(nil);
  // Init Rtti
  LType := TdjRTTI.Ctx.GetType(AObjAsDuck.ClassInfo);
  if not Assigned(LType) then Exit(nil);
  // Keys Property
  LKeysProperty := LType.GetProperty('Keys');
  if not Assigned(LKeysProperty) then Exit(nil);
  // Values Property
  LValuesProperty := LType.GetProperty('Values');
  if not Assigned(LValuesProperty) then Exit(nil);
  // Keys Property
  LCountProperty := LType.GetProperty('Count');
  if not Assigned(LCountProperty) then Exit(nil);
  // Add method
  LAddMethod := LType.GetMethod('Add');
  if not Assigned(LAddMethod) then Exit(nil);
  // Keys enumerator
  LObj := nil;
  LObj := LKeysProperty.GetValue(AObjAsDuck).AsObject;
  LObj := TdjRTTI.Ctx.GetType(LObj.ClassInfo).GetMethod('GetEnumerator').Invoke(LObj, []).AsObject;
  LKeysEnumerator := TdjDuckDictionaryEnumerator.Create(   LObj   );
  // Values enumerator
  LObj := nil;
  LObj := LValuesProperty.GetValue(AObjAsDuck).AsObject;
  LObj := TdjRTTI.Ctx.GetType(LObj.ClassInfo).GetMethod('GetEnumerator').Invoke(LObj, []).AsObject;
  LValuesEnumerator := TdjDuckDictionaryEnumerator.Create(   LObj   );
  // If everithing is OK then create the Duck
  Result := Self.Create(AObjAsDuck, LKeysProperty, LValuesProperty, LCountProperty, LAddMethod, LKeysEnumerator, LValuesEnumerator);
end;

{ TdjDuckDictionaryEnumerator }

constructor TdjDuckDictionaryEnumerator.Create(AObjectAsDuck: TObject);
begin
  inherited Create;
  FObjectAsDuck := AObjectAsDuck;
  // GetCurrent method
  FCurrentProperty := TdjRTTI.Ctx.GetType(AObjectAsDuck.ClassInfo).GetProperty('Current');
  if not Assigned(FCurrentProperty) then
    raise EdsonDuckException.Create('Cannot find property "Current" in the duck object');
  // MoveNext method
  FMoveNextMethod := TdjRTTI.Ctx.GetType(AObjectAsDuck.ClassInfo).GetMethod('MoveNext');
  if not Assigned(FMoveNextMethod) then
    raise EdsonDuckException.Create('Cannot find method "MoveNext" in the duck object');
end;

function TdjDuckDictionaryEnumerator.Current: TValue;
begin
  Result := FCurrentProperty.GetValue(FObjectAsDuck);
end;

destructor TdjDuckDictionaryEnumerator.Destroy;
begin
  FObjectAsDuck.Free;
  inherited;
end;

function TdjDuckDictionaryEnumerator.MoveNext: Boolean;
begin
  Result := FMoveNextMethod.Invoke(FObjectAsDuck, []).AsBoolean;
end;

end.
