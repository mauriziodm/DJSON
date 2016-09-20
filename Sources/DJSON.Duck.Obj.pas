{***************************************************************************}
{                                                                           }
{           DJSONl - (Delphi JSON library)                                    }
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



unit DJSON.Duck.Obj;

interface

uses
  DJSON.Duck.Interfaces, System.Rtti, System.Classes;

type

  TdjDuckStreamable = class(TInterfacedObject, IdjDuckStreamable)
  strict protected
    FObjAsDuck: TObject;
    FLoadFromStreamMethod: TRttiMethod;
    FSaveToStreamMethod: TRttiMethod;
    FIsEmptyMethod: TRttiMethod;
    FCountProperty: TRttiProperty;
  public
    class function TryCreate(const AObjAsDuck:TObject): IdjDuckStreamable;
    constructor Create(const AObjAsDuck:TObject; const ALoadFromStreamMethod,ASaveToStreamMethod,AIsEmptyMethod:TRTTIMethod; const ACountProperty:TRTTIProperty);
    procedure LoadFromStream(AStream: TStream);
    procedure SaveToStream(AStream: TStream);
    function IsEmpty: Boolean;
  end;

implementation

uses
  DJSON.Utils.RTTI;

{ TdjDuckStreamable }

constructor TdjDuckStreamable.Create(const AObjAsDuck:TObject; const ALoadFromStreamMethod,ASaveToStreamMethod,AIsEmptyMethod:TRTTIMethod; const ACountProperty:TRTTIProperty);
begin
  inherited Create;
  FObjAsDuck := AObjAsDuck;
  FLoadFromStreamMethod := ALoadFromStreamMethod;
  FSaveToStreamMethod := ASaveToStreamMethod;
  FIsEmptyMethod := AIsEmptyMethod;
  FCountProperty := ACountProperty;
end;

function TdjDuckStreamable.IsEmpty: Boolean;
begin
  // FIsEmptyMethod method assigned
  if Assigned(FIsEmptyMethod)
    then Result := FIsEmptyMethod.Invoke(FObjAsDuck, []).AsBoolean
  // FCountProperty method assigned
  else if Assigned(FCountProperty)
    then Result := (FCountProperty.GetValue(FObjAsDuck).AsInteger = 0)
  // Otherwise return False
  else Result := False;
end;

procedure TdjDuckStreamable.LoadFromStream(AStream: TStream);
begin
  FLoadFromStreamMethod.Invoke(FObjAsDuck, [AStream]);
end;

procedure TdjDuckStreamable.SaveToStream(AStream: TStream);
begin
  FSaveToStreamMethod.Invoke(FObjAsDuck, [AStream]);
end;

class function TdjDuckStreamable.TryCreate(
  const AObjAsDuck: TObject): IdjDuckStreamable;
var
  LType: TRttiType;
  LLoadFromStreamMethod: TRttiMethod;
  LSaveToStreamMethod: TRttiMethod;
  LIsEmptyMethod: TRttiMethod;
  LCountProperty: TRttiProperty;
begin
  // Check received object
  if not Assigned(AObjAsDuck) then Exit(nil);
  // Init Rtti
  LType := TdjRTTI.Ctx.GetType(AObjAsDuck.ClassInfo);
  if not Assigned(LType) then Exit(nil);
  // LoadFromStream method
  LLoadFromStreamMethod := LType.GetMethod('LoadFromStream');
  if not Assigned(LLoadFromStreamMethod) then Exit(nil);
  // SaveToStream method
  LSaveToStreamMethod := LType.GetMethod('SaveToStream');
  if not Assigned(LSaveToStreamMethod) then Exit(nil);
  // IsEmpty method
  LIsEmptyMethod := LType.GetMethod('IsEmpty');
  // Count Property
  LCountProperty := LType.GetProperty('Count');
  // If everithing is OK then create the Duck
  Result := Self.Create(AObjAsDuck, LLoadFromStreamMethod, LSaveToStreamMethod, LIsEmptyMethod, LCountProperty);
end;

end.
