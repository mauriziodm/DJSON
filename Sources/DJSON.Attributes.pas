{***************************************************************************}
{                                                                           }
{           DJSON - (Delphi JSON library)                                   }
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



unit DJSON.Attributes;

interface

uses
  System.TypInfo, DJSON.Serializers, System.Rtti;

type

  // djSkip
  djSkipAttribute = class(TCustomAttribute)
  end;

  // djName
  djNameAttribute = class(TCustomAttribute)
  private
    FName: string;
    function GetName: string;
  public
    constructor Create(const AName: string);
    property Name: string read GetName;
  end;

  // djType
  djTypeAttribute = class(TCustomAttribute)
  private
    FQualifiedName: String;
  public
    constructor Create; overload;  // For initialization
    constructor Create(const Value: TClass); overload;  // Use with lists (for compatibility)
    constructor Create(const ATypeInfo: PTypeInfo); overload;  // Use with lists
    property QualifiedName: String read FQualifiedName;
  end;

  // djItemsType
  djItemsTypeAttribute = class(TCustomAttribute)
  private
    FKeyQualifiedName: String;
    FValueQualifiedName: String;
    procedure SetValue(const Value: TClass);
    function GetValue: TClass;
  public
    constructor Create; overload;  // For initialization
    constructor Create(const Value: TClass); overload;  // Use with lists (for compatibility)
    constructor Create(const AValueTypeInfo: PTypeInfo); overload;  // Use with lists
    constructor Create(const AKeyTypeInfo, AValueTypeInfo: PTypeInfo); overload;  // Use with TDIctionary
    property Value: TClass read GetValue write SetValue;
    property KeyQualifiedName: String read FKeyQualifiedName;
    property ValueQualifiedName: String read FValueQualifiedName;
  end;

  // djSerializer attributes
  djSerializerAttribute<T> = class(TCustomAttribute)
  private
    FSerializer: T;
  public
    constructor Create(const ASerializer:T);
    property Serializer:T read FSerializer;
  end;
  // djSerializerDOM
  djSerializerDOMAttribute = class(djSerializerAttribute<TdjDOMCustomSerializerRef>)
  end;
  // djSerializerJDO
  djSerializerJDOAttribute = class(djSerializerAttribute<TdjJDOCustomSerializerRef>)
  end;
  // djSerializerXML
  djSerializerXMLAttribute = class(djSerializerAttribute<TdjXMLCustomSerializerRef>)
  end;
  // djSerializerStream
  // djSerializerXML
  djSerializerStreamAttribute = class(djSerializerAttribute<TdjStreamCustomSerializerRef>)
  end;

  // djEncoding
  djEncodingAttribute = class(TCustomAttribute)
  strict private
    FEncoding: string;
    procedure SetEncoding(const Value: string);
  const
    DefaultEncoding = 'utf-8';
  public
    constructor Create(AEncoding: string = DefaultEncoding);
    property Encoding: string read FEncoding write SetEncoding;
  end;


implementation

uses
  System.SysUtils, DJSON.Utils.RTTI, System.Generics.Collections;

{ djEncodingAttribute }

constructor djEncodingAttribute.Create(AEncoding: string);
begin
  inherited Create;
  if AEncoding.IsEmpty then
    FEncoding := DefaultEncoding
  else
    FEncoding := AEncoding;
end;

procedure djEncodingAttribute.SetEncoding(const Value: string);
begin
  FEncoding := Value;
end;

{ djNameAttribute }

constructor djNameAttribute.Create(const AName: string);
begin
  inherited Create;
  FName := AName;
end;

function djNameAttribute.GetName: string;
begin
  Result := FName;
end;

{ djItemsTypeAttribute }

constructor djItemsTypeAttribute.Create(const Value: TClass);
begin
  Self.Create(Value.ClassInfo);
end;

constructor djItemsTypeAttribute.Create;
begin
  inherited Create;
  // Init
  FKeyQualifiedName   := '';
  FValueQualifiedName := '';
end;

constructor djItemsTypeAttribute.Create(const AValueTypeInfo: PTypeInfo);
begin
  Self.Create;
  // Extract the qualified type name for the values
  FValueQualifiedName := TdjRTTI.TypeInfoToQualifiedTypeName(AValueTypeInfo);
end;

constructor djItemsTypeAttribute.Create(const AKeyTypeInfo,
  AValueTypeInfo: PTypeInfo);
begin
  // Extract the qualified type name for the values
  Self.Create(AValueTypeInfo);
  // Extract the qualified type name for the Keys
  FKeyQualifiedName := TdjRTTI.TypeInfoToQualifiedTypeName(AKeyTypeInfo);
end;

function djItemsTypeAttribute.GetValue: TClass;
var
  typ: TRttiType;
begin
  inherited;
  typ := TdjRTTI.QualifiedTypeNameToRttiType(FValueQualifiedName);
  if Assigned(typ) and typ.IsInstance then
    Result := typ.AsInstance.MetaclassType;
end;

procedure djItemsTypeAttribute.SetValue(const Value: TClass);
begin
  FValueQualifiedName := Value.QualifiedClassName;
end;

{ djTypeAttribute }

constructor djTypeAttribute.Create;
begin
  inherited Create;
  // Init
  FQualifiedName := '';
end;

constructor djTypeAttribute.Create(const Value: TClass);
begin
  Self.Create(Value.ClassInfo);
end;

constructor djTypeAttribute.Create(const ATypeInfo: PTypeInfo);
begin
  Self.Create;
  // Extract the qualified type name for the values
  FQualifiedName := TdjRTTI.TypeInfoToQualifiedTypeName(ATypeInfo);
end;

{ djSerializerAttribute<T> }

constructor djSerializerAttribute<T>.Create(const ASerializer: T);
begin
  FSerializer := ASerializer;
end;

end.

