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



unit DJSON.Params;

interface

uses
  System.TypInfo, DJSON.Serializers, System.Generics.Collections, System.Rtti,
  DJSON.TypeInfoCache;

type

  TdjEngine = (eDelphiDOM, eDelphiStream, eJDO);

  TdjNameCase = (ncUndefinedCase, ncUpperCase, ncLowerCase);

  TdjSerializationMode = (smJavaScript, smDataContract);

  TdjSerializationType = (stProperties, stFields);

  TdjIgnoredProperties = array of string;

  TdjSerializersContainer = class;

  IdjParams = interface;

  TdjEngineRef = class of TdjEngineIntf;
  TdjEngineIntf = class abstract
  public
    class function Serialize(const AValue: TValue; const APropField: TRttiNamedObject; const AParams: IdjParams; const AEnableCustomSerializers:Boolean=True): String; virtual; abstract;
    class function Deserialize(const AJSONText:String; const AValueType: TRttiType; const APropField: TRttiNamedObject; const AMasterObj: TObject; const AParams: IdjParams): TValue; virtual; abstract;
  end;

  IdjParams = interface
    ['{347611D7-F62B-49DB-B08A-E158D466F8AE}']
    // Engine (No property)
    function GetEngineClass: TdjEngineRef;
    // EngineType
    procedure SetEngine(const AValue: TdjEngine);
    function GetEngine: TdjEngine;
    property Engine: TdjEngine read GetEngine write SetEngine;
    // SerializationMode
    procedure SetSerializationMode(const AValue: TdjSerializationMode);
    function GetSerializationMode: TdjSerializationMode;
    property SerializationMode: TdjSerializationMode read GetSerializationMode write SetSerializationMode;
    // SerializationType
    procedure SetSerializationType(const AValue: TdjSerializationType);
    function GetSerializationType: TdjSerializationType;
    property SerializationType: TdjSerializationType read GetSerializationType write SetSerializationType;
    // TypeAnnotations
    procedure SetTypeAnnotations(const AValue: Boolean);
    function GetTypeAnnotations: Boolean;
    property TypeAnnotations: Boolean read GetTypeAnnotations write SetTypeAnnotations;
    // IgnoredProperties
    procedure SetIgnoredProperties(const AValue: TdjIgnoredProperties);
    function GetIgnoredProperties: TdjIgnoredProperties;
    property IgnoredProperties: TdjIgnoredProperties read GetIgnoredProperties write SetIgnoredProperties;
    // EnableCustomSerializers
    procedure SetEnableCustomSerializers(const AValue: Boolean);
    function GetEnableCustomSerializers: Boolean;
    property EnableCustomSerializers: Boolean read GetEnableCustomSerializers write SetEnableCustomSerializers;
    // Serializers
    function GetSerializers: TdjSerializersContainer;
    property Serializers: TdjSerializersContainer read GetSerializers;
    // TypeInfoCache
    function TypeInfoCache: TdjTypeInfoCache;
    // ItemsKeyDefaultQualifiedName
    procedure SetItemsKeyDefaultQualifiedName(const AValue:String);
    function GetItemsKeyDefaultQualifiedName: String;
    property ItemsKeyDefaultQualifiedName: String read GetItemsKeyDefaultQualifiedName write SetItemsKeyDefaultQualifiedName;
    // ItemsValueDefaultQualifiedName
    procedure SetItemsValueDefaultQualifiedName(const AValue:String);
    function GetItemsValueDefaultQualifiedName: String;
    property ItemsValueDefaultQualifiedName: String read GetItemsValueDefaultQualifiedName write SetItemsValueDefaultQualifiedName;
    // ItemsKeyDefaultTypeInfo
    procedure SetItemsKeyDefaultTypeInfo(const AValue:PTypeInfo);
    function GetItemsKeyDefaultTypeInfo: PTypeInfo;
    property ItemsKeyDefaultTypeInfo: PTypeInfo read GetItemsKeyDefaultTypeInfo write SetItemsKeyDefaultTypeInfo;
    // ItemsValueDefaultTypeInfo
    procedure SetItemsValueDefaultTypeInfo(const AValue:PTypeInfo);
    function GetItemsValueDefaultTypeInfo: PTypeInfo;
    property ItemsValueDefaultTypeInfo: PTypeInfo read GetItemsValueDefaultTypeInfo write SetItemsValueDefaultTypeInfo;
    // OwnJSONValue
    procedure SetOwnJSONValue(const AValue:Boolean);
    function GetOwnJSONValue: Boolean;
    property OwnJSONValue: Boolean read GetOwnJSONValue write SetOwnJSONValue;
    // NameCase
    procedure SetNameCase(const AValue:TdjNameCase);
    function GetNameCase: TdjNameCase;
    property NameCase: TdjNameCase read GetNameCase write SetNameCase;
  end;

  TdjParams = class(TInterfacedObject, IdjParams)
  strict private
    FEngineClass: TdjEngineRef;
    FEngineType: TdjEngine;
    FSerializationMode: TdjSerializationMode;
    FSerializationType: TdjSerializationType;
    FTypeAnnotations: Boolean;
    FIgnoredProperties: TdjIgnoredProperties;
    FEnableCustomSerializers: Boolean;
    FSerializers: TdjSerializersContainer;
    FItemsKeyDefaultQualifiedName: String;
    FItemsValueDefaultQualifiedName: String;
    FOwnJSONValue: Boolean;
    FNameCase: TdjNameCase;
    FTypeInfoCache: TdjTypeInfoCache;
    // Engine (No property)
    function GetEngineClass: TdjEngineRef;
    // EngineType
    procedure SetEngine(const AValue: TdjEngine);
    function GetEngine: TdjEngine;
    // SerializationMode
    procedure SetSerializationMode(const AValue: TdjSerializationMode);
    function GetSerializationMode: TdjSerializationMode;
    // SerializationType
    procedure SetSerializationType(const AValue: TdjSerializationType);
    function GetSerializationType: TdjSerializationType;
    // DataTypesAnnotation
    procedure SetTypeAnnotations(const AValue: Boolean);
    function GetTypeAnnotations: Boolean;
    // IgnoredProperties
    procedure SetIgnoredProperties(const AValue: TdjIgnoredProperties);
    function GetIgnoredProperties: TdjIgnoredProperties;
    // EnableCustomSerializers
    procedure SetEnableCustomSerializers(const AValue: Boolean);
    function GetEnableCustomSerializers: Boolean;
    // Serializers
    function GetSerializers: TdjSerializersContainer;
    // TypeInfoCache
    function TypeInfoCache: TdjTypeInfoCache;
    // ItemsKeyDefaultQualifiedName
    procedure SetItemsKeyDefaultQualifiedName(const AValue:String);
    function GetItemsKeyDefaultQualifiedName: String;
    // ItemsValueDefaultQualifiedName
    procedure SetItemsValueDefaultQualifiedName(const AValue:String);
    function GetItemsValueDefaultQualifiedName: String;
    // ItemsKeyDefaultTypeInfo
    procedure SetItemsKeyDefaultTypeInfo(const AValue:PTypeInfo);
    function GetItemsKeyDefaultTypeInfo: PTypeInfo;
    // ItemsValueDefaultTypeInfo
    procedure SetItemsValueDefaultTypeInfo(const AValue:PTypeInfo);
    function GetItemsValueDefaultTypeInfo: PTypeInfo;
    // OwnJSONValue
    procedure SetOwnJSONValue(const AValue:Boolean);
    function GetOwnJSONValue: Boolean;
    // NameCase
    procedure SetNameCase(const AValue:TdjNameCase);
    function GetNameCase: TdjNameCase;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TdjSerializersContainerItem = class
  strict private
    FParams: IdjParams;
    FSerializer: TdjCustomSerializerRef;
    function GetSerializer: TdjCustomSerializerRef;
    procedure SetSerializer(const Value: TdjCustomSerializerRef);
    function GetParams: IdjParams;
    procedure SetParams(const Value: IdjParams);
  public
    constructor Create(const ASerializer:TdjCustomSerializerRef; const AParams:IdjParams); overload;
    property Serializer:TdjCustomSerializerRef read GetSerializer write SetSerializer;
    property Params:IdjParams read GetParams write SetParams;
  end;

  TdjSerializersContainer = class
  strict private
    FSerializersContainer: TObjectDictionary<String, TdjSerializersContainerItem>;
  public
    constructor Create;
    destructor Destroy; override;
    procedure &Register(const ATargetTypeInfo:PTypeInfo; const ASerializer:TdjCustomSerializerRef; const AParams:IdjParams=nil); overload;
    procedure &Register(const ATargetClass:TClass; const ASerializer:TdjCustomSerializerRef; const AParams:IdjParams=nil); overload;
    procedure &Register<Target>(const ASerializer:TdjCustomSerializerRef; const AParams:IdjParams=nil); overload;
    procedure &Register<Target; Serializer:TdjCustomSerializer>(const AParams:IdjParams=nil); overload;
    procedure Unregister(const ATargetTypeInfo:PTypeInfo); overload;
    procedure Unregister(const ATargetClass:TClass); overload;
    procedure Unregister<T>; overload;
    function _GetSerializerItem(const ATargetTypeInfo:PTypeInfo): TdjSerializersContainerItem;
    function _Exists(const ATargetTypeInfo:PTypeInfo): Boolean;
    function Exists(const ATargetTypeInfo:PTypeInfo): Boolean; overload;
    function Exists(const ATargetClass:TClass): Boolean; overload;
    function Exists<T>: Boolean; overload;
  end;

implementation

uses
  DJSON.Utils.RTTI, DJSON.Factory;

{ TdjParams }

constructor TdjParams.Create;
begin
  inherited;
//  SetEngine(TdjEngine.eDelphiStream);
  SetEngine(TdjEngine.eDelphiDOM);
  FTypeInfoCache := TdjTypeInfoCache.Create;
  FSerializers := TdjSerializersContainer.Create;
  FTypeAnnotations := False;
  FEnableCustomSerializers := False;
  FItemsKeyDefaultQualifiedName := 'System.String';
  FItemsValueDefaultQualifiedName := '';
  FOwnJSONValue := False; // JSONValue is not owned by default
  FNameCase := ncUndefinedCase;
end;

destructor TdjParams.Destroy;
begin
  FTypeInfoCache.Free;
  FSerializers.Free;
  inherited;
end;

function TdjParams.GetTypeAnnotations: Boolean;
begin
  Result := FTypeAnnotations;
end;

function TdjParams.GetEnableCustomSerializers: Boolean;
begin
  Result := FEnableCustomSerializers;
end;

function TdjParams.GetEngineClass: TdjEngineRef;
begin
  Result := FEngineClass;
end;

function TdjParams.GetEngine: TdjEngine;
begin
  Result := FEngineType;
end;

function TdjParams.GetIgnoredProperties: TdjIgnoredProperties;
begin
  Result := FIgnoredProperties;
end;

function TdjParams.GetItemsKeyDefaultQualifiedName: String;
begin
  Result := FItemsKeyDefaultQualifiedName;
end;

function TdjParams.GetItemsKeyDefaultTypeInfo: PTypeInfo;
begin
  Result := TdjRTTI.QualifiedTypeNameToRttiType(FItemsKeyDefaultQualifiedName).Handle;
end;

function TdjParams.GetItemsValueDefaultQualifiedName: String;
begin
  Result := FItemsValueDefaultQualifiedName;
end;

function TdjParams.GetItemsValueDefaultTypeInfo: PTypeInfo;
begin
  Result := TdjRTTI.QualifiedTypeNameToRttiType(FItemsValueDefaultQualifiedName).Handle;
end;

function TdjParams.GetNameCase: TdjNameCase;
begin
  Result := FNameCase;
end;

function TdjParams.GetOwnJSONValue: Boolean;
begin
  Result := FOwnJSONValue;
end;

function TdjParams.GetSerializationMode: TdjSerializationMode;
begin
  Result := FSerializationMode;
end;

function TdjParams.GetSerializationType: TdjSerializationType;
begin
  Result := FSerializationType;
end;

function TdjParams.GetSerializers: TdjSerializersContainer;
begin
  Result := FSerializers;
end;

procedure TdjParams.SetTypeAnnotations(const AValue: Boolean);
begin
  FTypeAnnotations := AValue;
end;

function TdjParams.TypeInfoCache: TdjTypeInfoCache;
begin
  Result := FTypeInfoCache;
end;

procedure TdjParams.SetEnableCustomSerializers(const AValue: Boolean);
begin
 FEnableCustomSerializers := AValue;
end;

procedure TdjParams.SetEngine(const AValue: TdjEngine);
begin
  FEngineType := AValue;
  // Set the engine
  FEngineClass := TdjFactory.GetEngine(AValue);
end;

procedure TdjParams.SetIgnoredProperties(const AValue: TdjIgnoredProperties);
begin
  FIgnoredProperties := AValue;
end;

procedure TdjParams.SetItemsKeyDefaultQualifiedName(const AValue: String);
begin
  FItemsKeyDefaultQualifiedName := AValue;
end;

procedure TdjParams.SetItemsKeyDefaultTypeInfo(const AValue: PTypeInfo);
begin
  FItemsKeyDefaultQualifiedName := TdjRTTI.TypeInfoToRttiType(AValue).QualifiedName;
end;

procedure TdjParams.SetItemsValueDefaultQualifiedName(const AValue: String);
begin
  FItemsValueDefaultQualifiedName := AValue;
end;

procedure TdjParams.SetItemsValueDefaultTypeInfo(const AValue: PTypeInfo);
begin
  FItemsValueDefaultQualifiedName := TdjRTTI.TypeInfoToRttiType(AValue).QualifiedName;
end;

procedure TdjParams.SetNameCase(const AValue: TdjNameCase);
begin
  FNameCase := AValue;
end;

procedure TdjParams.SetOwnJSONValue(const AValue: Boolean);
begin
  FOwnJSONValue := AValue;
end;

procedure TdjParams.SetSerializationMode(const AValue: TdjSerializationMode);
begin
  FSerializationMode := AValue;
end;

procedure TdjParams.SetSerializationType(const AValue: TdjSerializationType);
begin
  FSerializationType := AValue;
end;

{ TdjSerializersContainerItem }

constructor TdjSerializersContainerItem.Create(
  const ASerializer: TdjCustomSerializerRef; const AParams: IdjParams);
begin
  inherited Create;
  FSerializer := ASerializer;
  FParams := AParams;
end;

function TdjSerializersContainerItem.GetParams: IdjParams;
begin
  Result := FParams;
end;

function TdjSerializersContainerItem.GetSerializer: TdjCustomSerializerRef;
begin
  Result := FSerializer;
end;

procedure TdjSerializersContainerItem.SetParams(const Value: IdjParams);
begin
  FParams := Value;
end;

procedure TdjSerializersContainerItem.SetSerializer(
  const Value: TdjCustomSerializerRef);
begin
  FSerializer := Value;
end;

{ TdjSerializersContainer }

constructor TdjSerializersContainer.Create;
begin
  inherited;
  FSerializersContainer := TObjectDictionary<String, TdjSerializersContainerItem>.Create([doOwnsValues]);
end;

destructor TdjSerializersContainer.Destroy;
begin
  FSerializersContainer.Free;
  inherited;
end;

function TdjSerializersContainer.Exists(const ATargetClass: TClass): Boolean;
begin
  Result := Self._Exists(ATargetClass.ClassInfo);
end;

function TdjSerializersContainer.Exists(
  const ATargetTypeInfo: PTypeInfo): Boolean;
begin
  Result := Self._Exists(ATargetTypeInfo);
end;

function TdjSerializersContainer.Exists<T>: Boolean;
begin
  Result := Self._Exists(TypeInfo(T));
end;

procedure TdjSerializersContainer.Register(const ATargetTypeInfo: PTypeInfo;
  const ASerializer: TdjCustomSerializerRef; const AParams: IdjParams);
begin
  FSerializersContainer.Add(
    TdjRTTI.TypeInfoToQualifiedTypeName(ATargetTypeInfo),
    TdjSerializersContainerItem.Create(ASerializer, AParams)
    );
end;

procedure TdjSerializersContainer.Register(const ATargetClass: TClass;
  const ASerializer: TdjCustomSerializerRef; const AParams: IdjParams);
begin
  Self.Register(ATargetClass.ClassInfo, ASerializer, AParams);
end;

procedure TdjSerializersContainer.Register<Target>(
  const ASerializer: TdjCustomSerializerRef; const AParams: IdjParams);
begin
  Self.Register(TypeInfo(Target), ASerializer, AParams);
end;

procedure TdjSerializersContainer.Register<Target; Serializer>(
  const AParams: IdjParams);
begin
  Self.Register(TypeInfo(Target), Serializer, AParams);
end;

procedure TdjSerializersContainer.Unregister(const ATargetTypeInfo: PTypeInfo);
begin
  FSerializersContainer.Remove(TdjRTTI.TypeInfoToQualifiedTypeName(ATargetTypeInfo));
end;

procedure TdjSerializersContainer.Unregister(const ATargetClass: TClass);
begin
  Self.Unregister(ATargetClass.ClassInfo);
end;

procedure TdjSerializersContainer.Unregister<T>;
begin
  Self.Unregister(TypeInfo(T));
end;

function TdjSerializersContainer._Exists(
  const ATargetTypeInfo: PTypeInfo): Boolean;
begin
  Result := FSerializersContainer.ContainsKey(TdjRTTI.TypeInfoToQualifiedTypeName(ATargetTypeInfo));
end;

function TdjSerializersContainer._GetSerializerItem(
  const ATargetTypeInfo:PTypeInfo): TdjSerializersContainerItem;
begin
  Result := FSerializersContainer.Items[TdjRTTI.TypeInfoToQualifiedTypeName(ATargetTypeInfo)];
end;

end.
