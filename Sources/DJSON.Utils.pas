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



unit DJSON.Utils;

interface

uses
  System.Rtti, DJSON.Params;

type

  TdjUtils = class
  public
    class function IsPropertyToBeIgnored(const APropField: TRttiNamedObject; const AParams: IdjParams): Boolean; static;
    class function GetKeyName(const ARttiMember: TRttiNamedObject; const AParams:IdjParams): string; static;
    class procedure GetTypeNameIfEmpty(const APropField: TRttiNamedObject; const AParams:IdjParams; var ATypeName: String); static;
    class procedure GetItemsTypeNameIfEmpty(const APropField: TRttiNamedObject; const AParams:IdjParams; var AValueTypeName: String); overload; static;
    class procedure GetItemsTypeNameIfEmpty(const APropField: TRttiNamedObject; const AParams:IdjParams; var AKeyTypeName, AValueTypeName: String); overload; static;
  end;

implementation

uses
  DJSON.Attributes, System.SysUtils, DJSON.Utils.RTTI, DJSON.Duck.PropField;

{ TdjUtils }

class procedure TdjUtils.GetItemsTypeNameIfEmpty(
  const APropField: TRttiNamedObject; const AParams: IdjParams;
  var AValueTypeName: String);
var
  LKeyTypeNameDummy: String;
begin
  LKeyTypeNameDummy := 'DummyKeyTypeName';
  GetItemsTypeNameIfEmpty(APropField, AParams, LKeyTypeNameDummy, AValueTypeName);
end;

class procedure TdjUtils.GetItemsTypeNameIfEmpty(
  const APropField: TRttiNamedObject; const AParams: IdjParams;
  var AKeyTypeName, AValueTypeName: String);
var
  LdsonItemsTypeAttribute: djItemsTypeAttribute;
begin
  // init
  LdsonItemsTypeAttribute := nil;
  // Only if needed
  if (not AKeyTypeName.IsEmpty) and (not AValueTypeName.IsEmpty) then
    Exit;
  // Get the attribute if exists (On the property or in the RttiType)
  if not TdjRTTI.HasAttribute<djItemsTypeAttribute>(APropField, LdsonItemsTypeAttribute) then
    TdjRTTI.HasAttribute<djItemsTypeAttribute>(TdjDuckPropField.RttiType(APropField), LdsonItemsTypeAttribute);
  // If the KeyType received as parameter is empty then get the type from
  //  the attribute and if also the attribute key type name is empty then
  //  get the default specified in the params
  if AKeyTypeName.IsEmpty then
  begin
    if Assigned(LdsonItemsTypeAttribute) and not LdsonItemsTypeAttribute.KeyQualifiedName.IsEmpty then
      AKeyTypeName := LdsonItemsTypeAttribute.KeyQualifiedName
    else
      AKeyTypeName := AParams.ItemsKeyDefaultQualifiedName;
  end;
  // If the ValueType received as parameter is empty then get the type from
  //  the attribute and if also the attribute value type name is empty then
  //  get the default specified in the params
  if AValueTypeName.IsEmpty then
  begin
    if Assigned(LdsonItemsTypeAttribute) and not LdsonItemsTypeAttribute.ValueQualifiedName.IsEmpty then
      AValueTypeName := LdsonItemsTypeAttribute.ValueQualifiedName
    else
      AValueTypeName := AParams.ItemsValueDefaultQualifiedName;
  end;
end;

class function TdjUtils.GetKeyName(const ARttiMember: TRttiNamedObject;
  const AParams:IdjParams): string;
var
  attrs: TArray<TCustomAttribute>;
  attr: TCustomAttribute;
  LdsonNameAttribute: djNameAttribute;
begin
  // If a dsonNameAttribute is present then use it else return the name
  //  of the property/field
  if TdjRTTI.HasAttribute<djNameAttribute>(ARttiMember, LdsonNameAttribute) then
    Result := LdsonNameAttribute.Name
  else
    Result := ARttiMember.Name;
  // If UpperCase or LowerCase names parama is specified...
  case AParams.NameCase of
    ncUpperCase: Result := UpperCase(ARttiMember.Name);
    ncLowerCase: Result := LowerCase(ARttiMember.Name);
  end;
end;

class procedure TdjUtils.GetTypeNameIfEmpty(
  const APropField: TRttiNamedObject; const AParams: IdjParams;
  var ATypeName: String);
var
  LdsonTypeAttribute: djTypeAttribute;
begin
  // init
  LdsonTypeAttribute := nil;
  // Only if needed
  if (not ATypeName.IsEmpty) then
    Exit;
  // Get the attribute if exists (On the property or in the RttiType)
  if not TdjRTTI.HasAttribute<djTypeAttribute>(APropField, LdsonTypeAttribute) then
    TdjRTTI.HasAttribute<djTypeAttribute>(TdjDuckPropField.RttiType(APropField), LdsonTypeAttribute);
  // If a dsonTypeAttritbute is found then retrieve the TypeName from it
  if Assigned(LdsonTypeAttribute) and not LdsonTypeAttribute.QualifiedName.IsEmpty then
    ATypeName := LdsonTypeAttribute.QualifiedName
end;

class function TdjUtils.IsPropertyToBeIgnored(
  const APropField: TRttiNamedObject; const AParams: IdjParams): Boolean;
var
  LIgnoredProperty: String;
begin
  for LIgnoredProperty in AParams.IgnoredProperties do
    if SameText(APropField.Name, LIgnoredProperty) then
      Exit(True);
  Exit(False);
end;

end.
