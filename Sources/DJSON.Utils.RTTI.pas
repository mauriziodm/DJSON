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



unit DJSON.Utils.RTTI;

interface

uses
  System.SysUtils, System.Rtti, System.TypInfo;

type

  TdjRTTI = class sealed
  private
    class var TValueToStringFormatSettings: TFormatSettings;
    class procedure Initialize; static;
  public
    class var Ctx: TRttiContext;
    class function TValueToObject(const AValue: TValue): TObject; static;
    class function TypeInfoToQualifiedTypeName(const ATypeInfo: PTypeInfo): String; static;
    class function TypeInfoToRttiType(const ATypeInfo: PTypeInfo): TRttiType; static;
    class function QualifiedTypeNameToRttiType(const AQualifiedTypeName:String): TRttiType; static;
    class function CreateObject(ARttiType: TRttiType): TObject; overload; static;
    class function CreateObject(AQualifiedClassName: string): TObject; overload; static;
    class function HasAttribute<T: class>(const ARTTIMember: TRttiNamedObject): boolean; overload;
    class function HasAttribute<T: class>(const ARTTIMember: TRttiNamedObject; out AAttribute: T): boolean; overload; static;
  end;

implementation

class function TdjRTTI.CreateObject(ARttiType: TRttiType): TObject;
var
  Method: TRttiMethod;
  metaClass: TClass;
begin
  { First solution, clear and slow }
  metaClass := nil;
  Method := nil;
  for Method in ARttiType.GetMethods do
    if Method.HasExtendedInfo and Method.IsConstructor then
      if Length(Method.GetParameters) = 0 then
      begin
        metaClass := ARttiType.AsInstance.MetaclassType;
        Break;
      end;
  if Assigned(metaClass) then
    Result := Method.Invoke(metaClass, []).AsObject
  else
    raise Exception.Create('Cannot find a propert constructor for ' +
      ARttiType.ToString);

  { Second solution, dirty and fast }
  // Result := TObject(ARttiType.GetMethod('Create')
  // .Invoke(ARttiType.AsInstance.MetaclassType, []).AsObject);
end;

class function TdjRTTI.CreateObject(AQualifiedClassName: string): TObject;
var
  rttitype: TRttiType;
begin
  rttitype := ctx.FindType(AQualifiedClassName);
  if Assigned(rttitype) then
    Result := CreateObject(rttitype)
  else
    raise Exception.Create('Cannot find RTTI for ' + AQualifiedClassName);
end;

class procedure TdjRTTI.Initialize;
begin
  Ctx := TRttiContext.Create;
  Ctx.FindType(''); // Workaround for thread safe: https://quality.embarcadero.com/browse/RSP-9815
end;

class function TdjRTTI.TValueToObject(const AValue: TValue): TObject;
begin
  Result := nil;
  case AValue.TypeInfo.Kind of
    tkInterface: Result := AValue.AsInterface As TObject;
    tkClass: Result := AValue.AsObject;
    else
      raise Exception.Create('TRTTIUtils.TValueToObject: The TValue does not contain an object or interfaced object.');
  end;
end;

class function TdjRTTI.TypeInfoToQualifiedTypeName(
  const ATypeInfo: PTypeInfo): String;
begin
  Result := Ctx.GetType(ATypeInfo).QualifiedName;
end;

class function TdjRTTI.TypeInfoToRttiType(
  const ATypeInfo: PTypeInfo): TRttiType;
begin
  Result := nil;
  Result := Ctx.GetType(ATypeInfo);
end;

class function TdjRTTI.HasAttribute<T>(
  const ARTTIMember: TRttiNamedObject): boolean;
var
  AAttribute: TCustomAttribute;
begin
  Result := HasAttribute<T>(ARTTIMember, AAttribute);
end;

class function TdjRTTI.HasAttribute<T>(const ARTTIMember: TRttiNamedObject;
  out AAttribute: T): boolean;
var
  attrs: TArray<TCustomAttribute>;
  attr: TCustomAttribute;
begin
  if not Assigned(ARTTIMember) then
    Exit(False);
  AAttribute := nil;
  Result := false;
  attrs := ARTTIMember.GetAttributes;
  for attr in attrs do
    if attr is T then
    begin
      AAttribute := T(attr);
      Exit(True);
    end;
end;

class function TdjRTTI.QualifiedTypeNameToRttiType(
  const AQualifiedTypeName: String): TRttiType;
begin
  Result := nil;
  Result := Ctx.FindType(AQualifiedTypeName);
end;

initialization

  TdjRTTI.Initialize;

end.
