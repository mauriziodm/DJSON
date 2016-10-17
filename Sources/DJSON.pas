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
  DJSON.Params, System.Rtti, System.JSON, System.TypInfo, DJSON.Serializers,
  System.SysUtils, System.Classes;

type

  TdjValueDestination = class;
  TdjJSONDestination  = class;
  TdjBSONDestination  = class;

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
    class function FromJson(const AJSONText:String; const AParams:IdjParams=nil): TdjJSONDestination;
    class function FromBson(const ABytesStream:TStream; const AParams:IdjParams=nil): TdjBSONDestination; overload;
    class function FromBson(const ABytes:TBytes; const AParams:IdjParams=nil): TdjBSONDestination; overload;
  end;

  TdjValueDestination = class
  strict private
    FValue: TValue;
    FParams: IdjParams;
  public
    constructor Create(const AValue: TValue; const AParams:IdjParams);
    // Destinations
    function ToJson: String;
    function ToBsonAsStream: TBytesStream;
    function ToBsonAsBytes: TBytes;
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
    function CustomSerializer(const ATargetTypeInfo:PTypeInfo; const ASerializer:TdjDOMCustomSerializerRef): TdjValueDestination; overload;
    function CustomSerializer(const ATargetTypeInfo:PTypeInfo; const ASerializer:TdjJDOCustomSerializerRef): TdjValueDestination; overload;
    function CustomSerializer(const ATargetTypeInfo:PTypeInfo; const ASerializer:TdjXMLCustomSerializerRef): TdjValueDestination; overload;
    function CustomSerializer(const ATargetTypeInfo:PTypeInfo; const ASerializer:TdjStreamCustomSerializerRef): TdjValueDestination; overload;
    function CustomSerializer(const ATargetClass:TClass; const ASerializer:TdjDOMCustomSerializerRef): TdjValueDestination; overload;
    function CustomSerializer(const ATargetClass:TClass; const ASerializer:TdjJDOCustomSerializerRef): TdjValueDestination; overload;
    function CustomSerializer(const ATargetClass:TClass; const ASerializer:TdjXMLCustomSerializerRef): TdjValueDestination; overload;
    function CustomSerializer(const ATargetClass:TClass; const ASerializer:TdjStreamCustomSerializerRef): TdjValueDestination; overload;
    function CustomSerializer<Target; Serializer:TdjDOMCustomSerializer>: TdjValueDestination; overload;
    function UpperCase: TdjValueDestination;
    function LowerCase: TdjValueDestination;
    function Engine(const AEngine:TdjEngine): TdjValueDestination;
  end;

  TdjJSONDestination = class
  strict private
    FJSONText: String;
  strict protected
    FParams: IdjParams;
  public
    constructor Create(const AJSONText:String; const AParams:IdjParams);
    // Destinations
    function ToValue(const ATypeValue:PTypeInfo): TValue; virtual;
    function ToObject: TObject; virtual;
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
    function CustomSerializer(const ATargetTypeInfo:PTypeInfo; const ASerializer:TdjDOMCustomSerializerRef): TdjJSONDestination; overload;
    function CustomSerializer(const ATargetTypeInfo:PTypeInfo; const ASerializer:TdjJDOCustomSerializerRef): TdjJSONDestination; overload;
    function CustomSerializer(const ATargetTypeInfo:PTypeInfo; const ASerializer:TdjXMLCustomSerializerRef): TdjJSONDestination; overload;
    function CustomSerializer(const ATargetTypeInfo:PTypeInfo; const ASerializer:TdjStreamCustomSerializerRef): TdjJSONDestination; overload;
    function CustomSerializer(const ATargetClass:TClass; const ASerializer:TdjDOMCustomSerializerRef): TdjJSONDestination; overload;
    function CustomSerializer(const ATargetClass:TClass; const ASerializer:TdjJDOCustomSerializerRef): TdjJSONDestination; overload;
    function CustomSerializer(const ATargetClass:TClass; const ASerializer:TdjXMLCustomSerializerRef): TdjJSONDestination; overload;
    function CustomSerializer(const ATargetClass:TClass; const ASerializer:TdjStreamCustomSerializerRef): TdjJSONDestination; overload;
    function CustomSerializer<Target; Serializer:TdjDOMCustomSerializer>: TdjJSONDestination; overload;
    function Engine(const AEngine:TdjEngine): TdjJSONDestination;
  end;

  TdjBSONDestination = class(TdjJSONDestination)
  strict private
    FBytesStream: TStream;
    FOwnStream: Boolean;
  public
    constructor Create(const ABytesStream:TStream; const AParams:IdjParams); overload;
    constructor Create(const ABytes:TBytes; const AParams:IdjParams); overload;
    destructor Destroy; override;
    // Destinations
    function ToValue(const ATypeValue:PTypeInfo): TValue; override;
    function ToObject: TObject; override;
    procedure &To(const AObject: TObject); overload;
  end;

implementation

uses
  DJSON.Factory, DJSON.Utils.RTTI, DJSON.Engine.DOM, DJSON.Constants, DJSON.Exceptions,
  DJSON.Engine.Stream, DJSON.Engine.JDO, DJSON.Engine.Stream.BSON;

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

class function dj.FromBson(const ABytesStream: TStream;
  const AParams: IdjParams): TdjBSONDestination;
begin
  Result := TdjBSONDestination.Create(ABytesStream, AParams);
end;

class function dj.FromBson(const ABytes: TBytes;
  const AParams: IdjParams): TdjBSONDestination;
begin
  Result := TdjBSONDestination.Create(ABytes, AParams);
end;

class function dj.FromJson(const AJSONText: String;
  const AParams: IdjParams): TdjJSONDestination;
begin
  Result := TdjJSONDestination.Create(AJSONText, AParams);
end;

{ TdjJSONDestination }

procedure TdjJSONDestination.&To(const AObject: TObject);
var
  LRttiType: TRttiType;
begin
  try
    LRttiType := TdjRTTI.TypeInfoToRttiType(AObject.ClassInfo);
    FParams.GetEngineClass.Deserialize(FJSONText, LRttiType, nil, AObject, FParams);
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

constructor TdjJSONDestination.Create(const AJSONText:String; const AParams:IdjParams);
begin
  inherited Create;
  FJSONText := AJSONText;
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
    Result := FParams.GetEngineClass.Deserialize(FJSONText, LRttiType, nil, nil, FParams);
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
  const ASerializer: TdjDOMCustomSerializerRef): TdjJSONDestination;
begin
  FParams.Serializers.Register(ATargetTypeInfo, ASerializer);
  Result := Self;
end;

function TdjJSONDestination.CustomSerializer(const ATargetClass: TClass;
  const ASerializer: TdjDOMCustomSerializerRef): TdjJSONDestination;
begin
  FParams.Serializers.Register(ATargetClass, ASerializer);
  Result := Self;
end;

function TdjJSONDestination.CustomSerializer(const ATargetTypeInfo: PTypeInfo;
  const ASerializer: TdjStreamCustomSerializerRef): TdjJSONDestination;
begin
  FParams.Serializers.Register(ATargetTypeInfo, ASerializer);
  Result := Self;
end;

function TdjJSONDestination.CustomSerializer(const ATargetTypeInfo: PTypeInfo;
  const ASerializer: TdjXMLCustomSerializerRef): TdjJSONDestination;
begin
  FParams.Serializers.Register(ATargetTypeInfo, ASerializer);
  Result := Self;
end;

function TdjJSONDestination.CustomSerializer(const ATargetTypeInfo: PTypeInfo;
  const ASerializer: TdjJDOCustomSerializerRef): TdjJSONDestination;
begin
  FParams.Serializers.Register(ATargetTypeInfo, ASerializer);
  Result := Self;
end;

function TdjJSONDestination.CustomSerializer(const ATargetClass: TClass;
  const ASerializer: TdjStreamCustomSerializerRef): TdjJSONDestination;
begin
  FParams.Serializers.Register(ATargetClass, ASerializer);
  Result := Self;
end;

function TdjJSONDestination.CustomSerializer(const ATargetClass: TClass;
  const ASerializer: TdjXMLCustomSerializerRef): TdjJSONDestination;
begin
  FParams.Serializers.Register(ATargetClass, ASerializer);
  Result := Self;
end;

function TdjJSONDestination.CustomSerializer(const ATargetClass: TClass;
  const ASerializer: TdjJDOCustomSerializerRef): TdjJSONDestination;
begin
  FParams.Serializers.Register(ATargetClass, ASerializer);
  Result := Self;
end;

function TdjJSONDestination.CustomSerializer<Target; Serializer>: TdjJSONDestination;
begin
  FParams.Serializers.Register<Target, Serializer>;
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

function TdjJSONDestination.Engine(
  const AEngine: TdjEngine): TdjJSONDestination;
begin
  FParams.Engine := AEngine;
  Result := Self;
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
  ResultValue: TValue;
begin
  try
    Result := nil;
    ResultValue := FParams.GetEngineClass.Deserialize(FJSONText, nil, nil, nil, FParams);
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
  const ASerializer: TdjDOMCustomSerializerRef): TdjValueDestination;
begin
  FParams.Serializers.Register(ATargetClass, ASerializer);
  Result := Self;
end;

function TdjValueDestination.CustomSerializer(const ATargetTypeInfo: PTypeInfo;
  const ASerializer: TdjDOMCustomSerializerRef): TdjValueDestination;
begin
  FParams.Serializers.Register(ATargetTypeInfo, ASerializer);
  Result := Self;
end;

function TdjValueDestination.CustomSerializer(const ATargetTypeInfo: PTypeInfo;
  const ASerializer: TdjJDOCustomSerializerRef): TdjValueDestination;
begin
  FParams.Serializers.Register(ATargetTypeInfo, ASerializer);
  Result := Self;
end;

function TdjValueDestination.CustomSerializer(const ATargetTypeInfo: PTypeInfo;
  const ASerializer: TdjXMLCustomSerializerRef): TdjValueDestination;
begin
  FParams.Serializers.Register(ATargetTypeInfo, ASerializer);
  Result := Self;
end;

function TdjValueDestination.CustomSerializer(const ATargetTypeInfo: PTypeInfo;
  const ASerializer: TdjStreamCustomSerializerRef): TdjValueDestination;
begin
  FParams.Serializers.Register(ATargetTypeInfo, ASerializer);
  Result := Self;
end;

function TdjValueDestination.CustomSerializer<Target, Serializer>: TdjValueDestination;
begin
  FParams.Serializers.Register<Target, Serializer>;
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

function TdjValueDestination.Engine(
  const AEngine: TdjEngine): TdjValueDestination;
begin
  FParams.Engine := AEngine;
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

function TdjValueDestination.ToBsonAsBytes: TBytes;
var
  LBytesStream: TBytesStream;
begin
  LBytesStream := Self.ToBsonAsStream;
  try
    Result := LBytesStream.Bytes;
    SetLength(Result, LBytesStream.Size);
  finally
    LBytesStream.Free;
  end;
end;

function TdjValueDestination.ToBsonAsStream: TBytesStream;
begin
  try
    Result := TdjEngineStreamBSON.Serialize(FValue, nil, FParams);
  finally
    Self.Free;
  end;
end;

function TdjValueDestination.ToJSON: String;
begin
  try
    Result := FParams.GetEngineClass.Serialize(FValue, nil, FParams);
  finally
    Self.Free;
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

function TdjValueDestination.CustomSerializer(const ATargetClass: TClass;
  const ASerializer: TdjJDOCustomSerializerRef): TdjValueDestination;
begin
  FParams.Serializers.Register(ATargetClass, ASerializer);
  Result := Self;
end;

function TdjValueDestination.CustomSerializer(const ATargetClass: TClass;
  const ASerializer: TdjXMLCustomSerializerRef): TdjValueDestination;
begin
  FParams.Serializers.Register(ATargetClass, ASerializer);
  Result := Self;
end;

function TdjValueDestination.CustomSerializer(const ATargetClass: TClass;
  const ASerializer: TdjStreamCustomSerializerRef): TdjValueDestination;
begin
  FParams.Serializers.Register(ATargetClass, ASerializer);
  Result := Self;
end;

{ TdjBSONDestination }

constructor TdjBSONDestination.Create(const ABytesStream: TStream;
  const AParams: IdjParams);
begin
  inherited Create('', AParams);
  FBytesStream := ABytesStream;
  FOwnStream := False;
end;

procedure TdjBSONDestination.&To(const AObject: TObject);
var
  LRttiType: TRttiType;
begin
  try
    LRttiType := TdjRTTI.TypeInfoToRttiType(AObject.ClassInfo);
    TdjEngineStreamBSON.Deserialize(FBytesStream, LRttiType, nil, AObject, FParams);
  finally
    Self.Free;
  end;
end;

constructor TdjBSONDestination.Create(const ABytes: TBytes;
  const AParams: IdjParams);
begin
  inherited Create('', AParams);
  FBytesStream := TBytesStream.Create(ABytes);
  FOwnStream := True;
end;

destructor TdjBSONDestination.Destroy;
begin
  if FOwnStream and Assigned(FBytesStream) then
    FBytesStream.Free;
  inherited;
end;

function TdjBSONDestination.ToObject: TObject;
var
  ResultValue: TValue;
begin
  try
    Result := nil;
    ResultValue := TdjEngineStreamBSON.Deserialize(FBytesStream, nil, nil, nil, FParams);
    Result := ResultValue.AsObject;
  finally
    Self.Free;
  end;
end;

function TdjBSONDestination.ToValue(const ATypeValue: PTypeInfo): TValue;
var
  LRttiType: TRttiType;
begin
  try
    LRttiType := TdjRTTI.TypeInfoToRttiType(ATypeValue);
    Result := TdjEngineStreamBSON.Deserialize(FBytesStream, LRttiType, nil, nil, FParams);
  finally
    Self.Free;
  end;
end;

end.
