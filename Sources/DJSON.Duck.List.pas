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



unit DJSON.Duck.List;

interface

uses
  DJSON.Duck.Interfaces, System.Rtti;

type

  TdjDuckList = class(TInterfacedObject, IdjDuckList)
  strict private
    FObjAsDuck: TObject;
    FCountProperty: TRttiProperty;
    FOwnsObjectsProperty: TRttiProperty;
    FAddMethod: TRttiMethod;
    FClearMethod: TRttiMethod;
    FGetItemMethod: TRttiMethod;
  strict protected
    procedure SetOwnsObjects(AValue:Boolean);
    function GetOwnsObjects: Boolean;
  public
    class function TryCreate(const AObjAsDuck:TObject): IdjDuckList;
    constructor Create(AObjAsDuck: TObject; const ACountProperty,AOwnsObjectsProperty:TRttiProperty; const AAddMethod,AClearMethod,AGetItemMethod:TRTTIMethod);
    procedure Add(AObj: TObject);
    procedure AddValue(const AValue: TValue);
    procedure Clear;
    procedure SetObject(const AObj:TObject);
    function Count: Integer;
    function GetItem(Index: Integer): TObject;
    function GetItemValue(const index: Integer): TValue;
    function GetGenericTypeName: String;
    function GetEnumerator: IEnumerator;
    property OwnsObjects:Boolean read GetOwnsObjects write SetOwnsObjects;
  end;

  TdjDuckListEnumerator = class(TInterfacedObject, IEnumerator)
  strict protected
    FPosition: Integer;
    FDuckTypedList: IdjDuckList;
  public
    constructor Create(ADuckTypedList: IdjDuckList);
    procedure Reset;
    function MoveNext: boolean;
    function GetCurrent: TObject;
    property Current: TObject read GetCurrent;
  end;

implementation

uses
  DJSON.Utils.RTTI, DJSON.Exceptions, System.TypInfo;

{ TdjDuckList }

procedure TdjDuckList.Add(AObj: TObject);
begin
  FAddMethod.Invoke(FObjAsDuck, [AObj]);
end;

procedure TdjDuckList.AddValue(const AValue: TValue);
begin
  FAddMethod.Invoke(FObjAsDuck, [AValue]);
end;

procedure TdjDuckList.Clear;
begin
  FClearMethod.Invoke(FObjAsDuck, []);
end;

function TdjDuckList.Count: Integer;
begin
  Result := FCountProperty.GetValue(FObjAsDuck).AsInteger;
end;

constructor TdjDuckList.Create(AObjAsDuck: TObject; const ACountProperty,AOwnsObjectsProperty:TRttiProperty; const AAddMethod,AClearMethod,AGetItemMethod:TRTTIMethod);
begin
  inherited Create;
  FObjAsDuck := AObjAsDuck;
  FCountProperty := ACountProperty;
  FOwnsObjectsProperty := AOwnsObjectsProperty;
  FAddMethod := AAddMethod;
  FClearMethod := AClearMethod;
  FGetItemMethod := AGetItemMethod;
end;

function TdjDuckList.GetEnumerator: IEnumerator;
begin
  Result := TdjDuckListEnumerator.Create(self);
end;

function TdjDuckList.GetItem(Index: Integer): TObject;
var
  AValue: TValue;
begin
  AValue := FGetItemMethod.Invoke(FObjAsDuck, [index]);
  case AValue.Kind of
    tkClass:
      Result := FGetItemMethod.Invoke(FObjAsDuck, [index]).AsObject;
    tkInterface:
      Result := FGetItemMethod.Invoke(FObjAsDuck, [index]).AsInterface as TObject;
  end;
end;

function TdjDuckList.GetItemValue(const index: Integer): TValue;
begin
  Result := FGetItemMethod.Invoke(FObjAsDuck, [index]);
end;

function TdjDuckList.GetGenericTypeName: String;
begin
  result := FGetItemMethod.ReturnType.ToString;
end;

function TdjDuckList.GetOwnsObjects: Boolean;
begin
  Result := False;
  if Assigned(FOwnsObjectsProperty) then
    Result := FOwnsObjectsProperty.GetValue(FObjAsDuck).AsBoolean;
end;

procedure TdjDuckList.SetObject(const AObj: TObject);
begin
  FObjAsDuck := AObj;
end;

procedure TdjDuckList.SetOwnsObjects(AValue: Boolean);
begin
  if Assigned(FOwnsObjectsProperty) then
    FOwnsObjectsProperty.SetValue(FObjAsDuck, AValue);
end;

class function TdjDuckList.TryCreate(const AObjAsDuck: TObject): IdjDuckList;
var
  LType: TRttiType;
  LCountProperty: TRttiProperty;
  LOwnsObjectsProperty: TRttiProperty;
  LAddMethod: TRttiMethod;
  LClearMethod: TRttiMethod;
  LGetItemMethod: TRttiMethod;
begin
  // Check received object
  if not Assigned(AObjAsDuck) then Exit(nil);
  // Init Rtti
  LType := TdjRTTI.Ctx.GetType(AObjAsDuck.ClassInfo);
  if not Assigned(LType) then Exit(nil);
  // Count Property
  LCountProperty := LType.GetProperty('Count');
  if not Assigned(LCountProperty) then Exit(nil);
  // Add method
  LAddMethod := LType.GetMethod('Add');
  if not Assigned(LAddMethod) then Exit(nil);
  // Clear
  LClearMethod := LType.GetMethod('Clear');
  if not Assigned(LClearMethod) then Exit(nil);
  // GetItem method
{$IF CompilerVersion >= 23}
  LGetItemMethod := LType.GetIndexedProperty('Items').ReadMethod;
{$IFEND}
  if not Assigned(LGetItemMethod) then LGetItemMethod := LType.GetMethod('GetItem');
  if not Assigned(LGetItemMethod) then LGetItemMethod := LType.GetMethod('GetElement');
  if not Assigned(LGetItemMethod) then Exit(nil);
  // OwnsObjects Property (No exception if not exist)
  LOwnsObjectsProperty := nil;
  LOwnsObjectsProperty := LType.GetProperty('OwnsObjects');
  // If everithing is OK then create the Duck
  Result := Self.Create(AObjAsDuck, LCountProperty, LOwnsObjectsProperty, LAddMethod, LClearMethod, LGetItemMethod);
end;

{ TdjDuckListEnumerator }

constructor TdjDuckListEnumerator.Create(ADuckTypedList: IdjDuckList);
begin
  inherited Create;
  FDuckTypedList := ADuckTypedList;
  FPosition := -1;
end;

function TdjDuckListEnumerator.GetCurrent: TObject;
begin
  if FPosition > -1 then
    Result := FDuckTypedList.GetItem(FPosition)
  else
    raise EdsonDuckException.Create(Self.ClassName + ': Call MoveNext first');
end;

function TdjDuckListEnumerator.MoveNext: boolean;
begin
  if FPosition < FDuckTypedList.Count - 1 then
  begin
    Inc(FPosition);
    Result := True;
  end else Result := false;
end;

procedure TdjDuckListEnumerator.Reset;
begin
  // Nothing but necessary
end;

end.
