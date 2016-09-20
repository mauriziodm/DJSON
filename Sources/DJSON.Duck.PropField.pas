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



unit DJSON.Duck.PropField;

interface

uses
  System.Rtti;

type

  TdjDuckPropFieldType = (ptInvalid, ptProperty, ptField);

  TdjDuckPropField = class
  public
    class function IsValidPropField(const ARttiType: TRttiNamedObject): Boolean; static;
    class function GetPropFieldType(const ARttiType: TRttiNamedObject): TdjDuckPropFieldType; static;
    class function GetValue(const Instance: TObject; const ARttiType: TRttiNamedObject): TValue; static;
    class procedure SetValue(const Instance: TObject; const ARttiType: TRttiNamedObject; const AValue: TValue); static;
    class function RttiType(const ARttiType: TRttiNamedObject): TRttiType; static;
    class function IsWritable(const ARttiType: TRttiNamedObject): Boolean; static;
    class function QualifiedName(const ARttiType: TRttiNamedObject): String; static;
    class function TypeKind(const ARttiType: TRttiNamedObject): TTypeKind; static;
  end;

implementation

uses
  DJSON.Exceptions;

{ TdjDuckPropField }

class function TdjDuckPropField.GetPropFieldType(const ARttiType: TRttiNamedObject): TdjDuckPropFieldType;
begin
  if ARttiType is TRttiProperty then
    Result := ptProperty
  else if ARttiType is TRttiField then
    Result := ptField
  else
    Result := ptInvalid;
end;

class function TdjDuckPropField.GetValue(const Instance: TObject; const ARttiType: TRttiNamedObject): TValue;
var
  LRttiProperty: TRttiProperty;
begin
  case GetPropFieldType(ARttiType) of
    ptField:
      Result := TRttiField(ARttiType).GetValue(Instance);
    ptProperty:
      Result := TRttiProperty(ARttiType).GetValue(Instance);
  else
      raise EdsonDuckException.CreateFmt('Invalid prop/field type $s', [ARttiType.Name]);
  end;
end;

class function TdjDuckPropField.IsValidPropField(
  const ARttiType: TRttiNamedObject): Boolean;
begin
  Result := Assigned(ARttiType) and (GetPropFieldType(ARttiType) <> ptInvalid);
end;

class function TdjDuckPropField.IsWritable(const ARttiType: TRttiNamedObject): Boolean;
begin
  case GetPropFieldType(ARttiType) of
    ptField:
      Result := True;
    ptProperty:
      Result := TRttiProperty(ARttiType).IsWritable;
  else
    Result := False;
  end;
end;

class function TdjDuckPropField.QualifiedName(
  const ARttiType: TRttiNamedObject): String;
begin
  Result := RttiType(ARttiType).QualifiedName;
end;

class function TdjDuckPropField.RttiType(const ARttiType: TRttiNamedObject): TRttiType;
begin
  case GetPropFieldType(ARttiType) of
    ptField:
      Result := TRttiField(ARttiType).FieldType;
    ptProperty:
      Result := TRttiProperty(ARttiType).PropertyType;
  else
    Result := ARttiType as TRttiType;
  end;
end;

class procedure TdjDuckPropField.SetValue(const Instance: TObject; const ARttiType: TRttiNamedObject; const AValue: TValue);
begin
  case GetPropFieldType(ARttiType) of
    ptField:
      TRttiField(ARttiType).SetValue(Instance, AValue);
    ptProperty:
      TRttiProperty(ARttiType).SetValue(Instance, AValue);
  else
      raise EdsonDuckException.CreateFmt('Invalid prop/field type $s', [ARttiType.Name]);
  end;
end;

class function TdjDuckPropField.TypeKind(const ARttiType: TRttiNamedObject): TTypeKind;
begin
  Result := RttiType(ARttiType).TypeKind;
end;

end.
