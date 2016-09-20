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



unit DJSON;

interface

uses
  DJSON.Params, System.Rtti, System.JSON, System.TypInfo, DJSON.Serializers;

type

  TdjValueDestination = class;
  TdjJSONDestination  = class;

  dj = class
  public
    // Parameters
    class function Default: IdjParams;
    class function DefaultByProperty: IdjParams;
    class function DefaultByFields: IdjParams;
    // Froms
    class function From(const AValue:TValue; const AParams:IdjParams=nil): TdjValueDestination; overload;
    class function From(const AObject:TObject; const AParams:IdjParams=nil): TdjValueDestination; overload;
    class function From(const AInterface:IInterface; const AParams:IdjParams=nil): TdjValueDestination; overload;
    class function FromJSON(const AJSONValue:TJSONValue; const AParams:IdjParams=nil): TdjJSONDestination; overload;
    class function FromJSON(const AJSONString:String; const AParams:IdjParams=nil): TdjJSONDestination; overload;
  end;

  TdjValueDestination = class
  strict private
    FValue: TValue;
    FParams: IdjParams;
  public
    constructor Create(const AValue: TValue; const AParams:IdjParams);
    // Destinations
    function ToJSON: TJSONValue;
    function ToString: String;
    // Params
    function Params(const AParams:IdjParams): TdjValueDestination;
    function ItemsOfType(const AValueType: PTypeInfo): TdjValueDestination; overload;
    function ItemsOfType(const AKeyType, AValueType: PTypeInfo): TdjValueDestination; overload;
    function ItemsOfType<Value>: TdjValueDestination; overload;
    function ItemsOfType<Key,Value>: TdjValueDestination; overload;
    function JavaScriptMode: TdjValueDestination;
    function DataContractMode: TdjValueDestination;
    function byProperties: TdjValueDestination;
    function byFields: TdjValueDestination;
    function TypeAnnotationsON: TdjValueDestination;
    function TypeAnnotationsOFF: TdjValueDestination;
    function CustomSerializersON: TdjValueDestination;
    function CustomSerializersOFF: TdjValueDestination;
    function CustomSerializer(const ATargetTypeInfo:PTypeInfo; const ASerializer:TdjCustomSerializerRef; const AParams:IdjParams=nil): TdjValueDestination; overload;
    function CustomSerializer(const ATargetClass:TClass; const ASerializer:TdjCustomSerializerRef; const AParams:IdjParams=nil): TdjValueDestination; overload;
    function CustomSerializer<Target>(const ASerializer:TdjCustomSerializerRef; const AParams:IdjParams=nil): TdjValueDestination; overload;
    function CustomSerializer<Target; Serializer:TdjCustomSerializer>(const AParams:IdjParams=nil): TdjValueDestination; overload;
    function UpperCase: TdjValueDestination;
    function LowerCase: TdjValueDestination;
  end;

  TdjJSONDestination = class
  strict private
    FValue: TJSONValue;
    FOwnJSONValue_Transient: Boolean;  // Usato da "FromJSON" con parametro stringa
    FParams: IdjParams;
  public
    constructor Create(const AValue: TJSONValue; const AParams:IdjParams);
    destructor Destroy; override;
    // Destinations
    function ToValue(const ATypeValue:PTypeInfo): TValue;
    function ToObject: TObject;
    function &To<T>: T; overload;
    procedure &To(const AObject: TObject); overload;
    procedure &To(const AInterface: IInterface); overload;
    // Params
    function Params(const AParams:IdjParams): TdjJSONDestination;
    function ItemsOfType(const AValueType: PTypeInfo): TdjJSONDestination; overload;
    function ItemsOfType(const AKeyType, AValueType: PTypeInfo): TdjJSONDestination; overload;
    function ItemsOfType<Value>: TdjJSONDestination; overload;
    function ItemsOfType<Key,Value>: TdjJSONDestination; overload;
    function JavaScriptMode: TdjJSONDestination;
    function DataContractMode: TdjJSONDestination;
    function byProperties: TdjJSONDestination;
    function byFields: TdjJSONDestination;
    function TypeAnnotationsON: TdjJSONDestination;
    function TypeAnnotationsOFF: TdjJSONDestination;
    function CustomSerializersON: TdjJSONDestination;
    function CustomSerializersOFF: TdjJSONDestination;
    function CustomSerializer(const ATargetTypeInfo:PTypeInfo; const ASerializer:TdjCustomSerializerRef; const AParams:IdjParams=nil): TdjJSONDestination; overload;
    function CustomSerializer(const ATargetClass:TClass; const ASerializer:TdjCustomSerializerRef; const AParams:IdjParams=nil): TdjJSONDestination; overload;
    function CustomSerializer<Target>(const ASerializer:TdjCustomSerializerRef; const AParams:IdjParams=nil): TdjJSONDestination; overload;
    function CustomSerializer<Target; Serializer:TdjCustomSerializer>(const AParams:IdjParams=nil): TdjJSONDestination; overload;
    function OwnJSONValue(const AOwnJSONValue: Boolean = True): TdjJSONDestination;
  end;

implementation

uses
  DJSON.Factory, DJSON.Utils.RTTI, DJSON.Engine.DOM, DJSON.Constants, DJSON.Exceptions;

{ dj }

class function dj.Default: IdjParams;
begin
  Result := DefaultByProperty;
end;

class function dj.DefaultByFields: IdjParams;
begin
  Result := TdjFactory.NewParams;
  Result.SerializationMode := smDataContract;
  Result.SerializationType := stFields;
  Result.TypeAnnotations := True;
end;

class function dj.DefaultByProperty: IdjParams;
begin
  Result := TdjFactory.NewParams;
  Result.SerializationMode := smJavaScript;
  Result.SerializationType := stProperties;
  Result.TypeAnnotations := False;
end;

class function dj.FromJSON(const AJSONValue:TJSONValue; const AParams:IdjParams=nil): TdjJSONDestination;
begin
  Result := TdjJSONDestination.Create(AJSONValue, AParams);
end;

class function dj.From(const AValue: TValue;
  const AParams: IdjParams): TdjValueDestination;
begin
  Result := TdjValueDestination.Create(AValue, AParams);
end;

class function dj.From(const AObject: TObject;
  const AParams: IdjParams): TdjValueDestination;
var
  LValue: TValue;
begin
  TValue.Make(@AObject, AObject.ClassInfo, LValue);
  Result := Self.From(LValue, AParams);
end;

class function dj.From(const AInterface: IInterface;
  const AParams: IdjParams): TdjValueDestination;
begin
  Result := Self.From(AInterface as TObject, AParams);
end;

class function dj.FromJSON(const AJSONString: String;
  const AParams: IdjParams): TdjJSONDestination;
begin
  Result := Self.FromJSON(TJSONObject.ParseJSONValue(AJSONString), AParams);
  Result.OwnJSONValue(True);
end;

{ TdjJSONDestination }

procedure TdjJSONDestination.&To(const AObject: TObject);
var
  LRttiType: TRttiType;
begin
  try
    LRttiType := TdjRTTI.TypeInfoToRttiType(AObject.ClassInfo);
    TdjEngineDOM.DeserializePropField(FValue, LRttiType, nil, AObject, FParams);
  finally
    Self.Free;
  end;
end;

procedure TdjJSONDestination.&To(const AInterface: IInterface);
begin
  Self.&To(AInterface as TObject);
end;

function TdjJSONDestination.byFields: TdjJSONDestination;
begin
  FParams.SerializationType := stFields;
  Result := Self;
end;

function TdjJSONDestination.byProperties: TdjJSONDestination;
begin
  FParams.SerializationType := stProperties;
  Result := Self;
end;

constructor TdjJSONDestination.Create(const AValue: TJSONValue; const AParams:IdjParams);
begin
  inherited Create;
  FValue := AValue;
  FOwnJSONValue_Transient := False; // JSONValue is not owned by default
  if Assigned(AParams) then
    FParams := AParams
  else
    FParams := dj.Default;
end;

function TdjJSONDestination.ToValue(const ATypeValue: PTypeInfo): TValue;
var
  LRttiType: TRttiType;
begin
  try
    LRttiType := TdjRTTI.TypeInfoToRttiType(ATypeValue);
    Result := TdjEngineDOM.DeserializePropField(FValue, LRttiType, nil, nil, FParams);
  finally
    Self.Free;
  end;
end;

function TdjJSONDestination.TypeAnnotationsOFF: TdjJSONDestination;
begin
  FParams.TypeAnnotations := False;
  Result := Self;
end;

function TdjJSONDestination.TypeAnnotationsON: TdjJSONDestination;
begin
  FParams.TypeAnnotations := True;
  Result := Self;
end;

function TdjJSONDestination.ItemsOfType(
  const AValueType: PTypeInfo): TdjJSONDestination;
begin
  FParams.ItemsValueDefaultTypeInfo := AValueType;
  Result := Self;
end;

function TdjJSONDestination.CustomSerializer(const ATargetTypeInfo: PTypeInfo;
  const ASerializer: TdjCustomSerializerRef;
  const AParams: IdjParams): TdjJSONDestination;
begin
  FParams.Serializers.Register(ATargetTypeInfo, ASerializer, AParams);
  Result := Self;
end;

function TdjJSONDestination.CustomSerializer(const ATargetClass: TClass;
  const ASerializer: TdjCustomSerializerRef;
  const AParams: IdjParams): TdjJSONDestination;
begin
  FParams.Serializers.Register(ATargetClass, ASerializer, AParams);
  Result := Self;
end;

function TdjJSONDestination.CustomSerializer<Target; Serializer>(
  const AParams: IdjParams): TdjJSONDestination;
begin
  FParams.Serializers.Register<Target, Serializer>(AParams);
  Result := Self;
end;

function TdjJSONDestination.CustomSerializer<Target>(
  const ASerializer: TdjCustomSerializerRef;
  const AParams: IdjParams): TdjJSONDestination;
begin
  FParams.Serializers.Register<Target>(ASerializer, AParams);
  Result := Self;
end;

function TdjJSONDestination.CustomSerializersOFF: TdjJSONDestination;
begin
  FParams.EnableCustomSerializers := False;
  Result := Self;
end;

function TdjJSONDestination.CustomSerializersON: TdjJSONDestination;
begin
  FParams.EnableCustomSerializers := True;
  Result := Self;
end;

function TdjJSONDestination.DataContractMode: TdjJSONDestination;
begin
  FParams.SerializationMode := smDataContract;
  Result := Self;
end;

destructor TdjJSONDestination.Destroy;
begin
  // Destroy the JSONValue if owned
  if (FParams.OwnJSONValue or FOwnJSONValue_Transient) and Assigned(FValue) then
    FValue.Free;
  inherited;
end;

function TdjJSONDestination.ItemsOfType(const AKeyType,
  AValueType: PTypeInfo): TdjJSONDestination;
begin
  FParams.ItemsKeyDefaultTypeInfo := AKeyType;
  FParams.ItemsValueDefaultTypeInfo := AValueType;
  Result := Self;
end;

function TdjJSONDestination.ItemsOfType<Key, Value>: TdjJSONDestination;
begin
  Result := Self.ItemsOfType(TypeInfo(Key), TypeInfo(Value));
end;

function TdjJSONDestination.ItemsOfType<Value>: TdjJSONDestination;
begin
  Result := Self.ItemsOfType(TypeInfo(Value));
end;

function TdjJSONDestination.JavaScriptMode: TdjJSONDestination;
begin
  FParams.SerializationMode := smJavaScript;
  Result := Self;
end;

function TdjJSONDestination.OwnJSONValue(
  const AOwnJSONValue: Boolean): TdjJSONDestination;
begin
  FOwnJSONValue_Transient := AOwnJSONValue;
  Result := Self;
end;

function TdjJSONDestination.Params(
  const AParams: IdjParams): TdjJSONDestination;
begin
  Self.FParams := AParams;
  Result := Self;
end;

function TdjJSONDestination.&To<T>: T;
begin
  Result := Self.ToValue(TypeInfo(T)).AsType<T>;
end;

function TdjJSONDestination.ToObject: TObject;
var
  LRttiType: TRttiType;
  ResultValue: TValue;
  LTypeJSONValue: TJSONValue;
begin
  try
    // Init
    LRttiType := nil;
    // Load types informations from the JSON
    if (FValue is TJSONObject) then begin
      // Retrieve the value type if embedded in JSON
      LTypeJSONValue := TJSONObject(FValue).GetValue(DJ_TYPENAME);
      if Assigned(LTypeJSONValue) then
        LRttiType := TdjRTTI.QualifiedTypeNameToRttiType(LTypeJSONValue.Value);
    end;
    // Check for destination Rtti validity
    if not Assigned(LRttiType) then
      raise EdjException.Create('Deserialize ToObject: Type informations not found.');
    // Deserialize
    ResultValue := TdjEngineDOM.DeserializePropField(FValue, LRttiType, nil, nil, FParams);
    Result := ResultValue.AsObject;
  finally
    Self.Free;
  end;
end;

{ TdjValueDestination }

function TdjValueDestination.byFields: TdjValueDestination;
begin
  FParams.SerializationType := stFields;
  Result := Self;
end;

function TdjValueDestination.byProperties: TdjValueDestination;
begin
  FParams.SerializationType := stProperties;
  Result := Self;
end;

constructor TdjValueDestination.Create(const AValue: TValue;
  const AParams: IdjParams);
begin
  inherited Create;
  FValue := AValue;
  if Assigned(AParams) then
    FParams := AParams
  else
    FParams := dj.Default;
end;

function TdjValueDestination.CustomSerializer(const ATargetClass: TClass;
  const ASerializer: TdjCustomSerializerRef;
  const AParams: IdjParams): TdjValueDestination;
begin
  FParams.Serializers.Register(ATargetClass, ASerializer, AParams);
  Result := Self;
end;

function TdjValueDestination.CustomSerializer(const ATargetTypeInfo: PTypeInfo;
  const ASerializer: TdjCustomSerializerRef;
  const AParams: IdjParams): TdjValueDestination;
begin
  FParams.Serializers.Register(ATargetTypeInfo, ASerializer, AParams);
  Result := Self;
end;

function TdjValueDestination.CustomSerializer<Target, Serializer>(
  const AParams: IdjParams): TdjValueDestination;
begin
  FParams.Serializers.Register<Target, Serializer>(AParams);
  Result := Self;
end;

function TdjValueDestination.CustomSerializer<Target>(
  const ASerializer: TdjCustomSerializerRef;
  const AParams: IdjParams): TdjValueDestination;
begin
  FParams.Serializers.Register<Target>(ASerializer, AParams);
  Result := Self;
end;

function TdjValueDestination.CustomSerializersOFF: TdjValueDestination;
begin
  FParams.EnableCustomSerializers := False;
  Result := Self;
end;

function TdjValueDestination.CustomSerializersON: TdjValueDestination;
begin
  FParams.EnableCustomSerializers := True;
  Result := Self;
end;

function TdjValueDestination.DataContractMode: TdjValueDestination;
begin
  FParams.SerializationMode := smDataContract;
  Result := Self;
end;

function TdjValueDestination.ItemsOfType(
  const AValueType: PTypeInfo): TdjValueDestination;
begin
  FParams.ItemsValueDefaultTypeInfo := AValueType;
  Result := Self;
end;

function TdjValueDestination.ItemsOfType(const AKeyType,
  AValueType: PTypeInfo): TdjValueDestination;
begin
  FParams.ItemsKeyDefaultTypeInfo := AKeyType;
  FParams.ItemsValueDefaultTypeInfo := AValueType;
  Result := Self;
end;

function TdjValueDestination.ItemsOfType<Key, Value>: TdjValueDestination;
begin
  Result := Self.ItemsOfType(TypeInfo(Key), TypeInfo(Value));
end;

function TdjValueDestination.ItemsOfType<Value>: TdjValueDestination;
begin
  Result := Self.ItemsOfType(TypeInfo(Value));
end;

function TdjValueDestination.JavaScriptMode: TdjValueDestination;
begin
  FParams.SerializationMode := smJavaScript;
  Result := Self;
end;

function TdjValueDestination.LowerCase: TdjValueDestination;
begin
  Self.FParams.NameCase := TdjNameCase.ncUpperCase;
  Result := Self;
end;

function TdjValueDestination.Params(
  const AParams: IdjParams): TdjValueDestination;
begin
  Self.FParams := AParams;
  Result := Self;
end;

function TdjValueDestination.ToJSON: TJSONValue;
var
  LRttiType: TRttiType;
begin
  try
    Result := TdjEngineDOM.SerializePropField(FValue, nil, FParams);
  finally
    Self.Free;
  end;
end;

function TdjValueDestination.ToString: String;
var
  LJSONValue: TJSONValue;
begin
  LJSONValue := Self.ToJSON;
  try
    Result := LJSONValue.ToString;
  finally
    LJSONValue.Free;
  end;
end;

function TdjValueDestination.TypeAnnotationsOFF: TdjValueDestination;
begin
  FParams.TypeAnnotations := False;
  Result := Self;
end;

function TdjValueDestination.TypeAnnotationsON: TdjValueDestination;
begin
  FParams.TypeAnnotations := True;
  Result := Self;
end;

function TdjValueDestination.UpperCase: TdjValueDestination;
begin
  Self.FParams.NameCase := TdjNameCase.ncLowerCase;
  Result := Self;
end;

end.
