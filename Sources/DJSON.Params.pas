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
    // BsonRoot
    procedure SetBsonRoot(const AValue:Boolean);
    function GetBsonRoot: Boolean;
    property BsonRoot: Boolean read GetBsonRoot write SetBsonRoot;
    // BsonRootLabel
    procedure SetBsonRootLabel(const AValue:String);
    function GetBsonRootLabel: String;
    property BsonRootLabel: String read GetBsonRootLabel write SetBsonRootLabel;
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
    FBsonRoot: Boolean;
    FBsonRootLabel: String;
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
    // BsonRoot
    procedure SetBsonRoot(const AValue:Boolean);
    function GetBsonRoot: Boolean;
    // BsonRootLabel
    procedure SetBsonRootLabel(const AValue:String);
    function GetBsonRootLabel: String;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  TdjSerializersContainerItem = class
  strict private
    FDOMSerializer: TdjDOMCustomSerializerRef;
    FJDOSerializer: TdjJDOCustomSerializerRef;
    FXMLSerializer: TdjXMLCustomSerializerRef;
    FStreamSerializer: TdjStreamCustomSerializerRef;
  public
    constructor Create;
    property DOMSerializer:TdjDOMCustomSerializerRef read FDOMSerializer write FDOMSerializer;
    property JDOSerializer:TdjJDOCustomSerializerRef read FJDOSerializer write FJDOSerializer;
    property XMLSerializer:TdjXMLCustomSerializerRef read FXMLSerializer write FXMLSerializer;
    property StreamSerializer:TdjStreamCustomSerializerRef read FStreamSerializer write FStreamSerializer;
  end;

  TdjSerializersContainer = class
  strict private
    FSerializersContainer: TObjectDictionary<String, TdjSerializersContainerItem>;
    function _GetOrCreateSerializersContainerItem(const ATargetTypeInfo:PTypeInfo): TdjSerializersContainerItem;
  public
    constructor Create;
    destructor Destroy; override;
    procedure &Register(const ATargetTypeInfo:PTypeInfo; const ASerializer:TdjDOMCustomSerializerRef); overload;
    procedure &Register(const ATargetTypeInfo:PTypeInfo; const ASerializer:TdjJDOCustomSerializerRef); overload;
    procedure &Register(const ATargetTypeInfo:PTypeInfo; const ASerializer:TdjXMLCustomSerializerRef); overload;
    procedure &Register(const ATargetTypeInfo:PTypeInfo; const ASerializer:TdjStreamCustomSerializerRef); overload;
    procedure &Register(const ATargetClass:TClass; const ASerializer:TdjDOMCustomSerializerRef); overload;
    procedure &Register(const ATargetClass:TClass; const ASerializer:TdjJDOCustomSerializerRef); overload;
    procedure &Register(const ATargetClass:TClass; const ASerializer:TdjXMLCustomSerializerRef); overload;
    procedure &Register(const ATargetClass:TClass; const ASerializer:TdjStreamCustomSerializerRef); overload;
    procedure &Register<Target; Serializer:TdjDOMCustomSerializer>; overload;
    procedure Unregister(const ATargetTypeInfo:PTypeInfo); overload;
    procedure Unregister(const ATargetClass:TClass); overload;
    procedure Unregister<T>; overload;
    function _GetSerializerItem(const ATargetTypeInfo:PTypeInfo): TdjSerializersContainerItem;
    function _Exists(const ATargetTypeInfo:PTypeInfo): Boolean;
    function Exists_DOM(const ATargetTypeInfo:PTypeInfo): Boolean; overload;
    function Exists_JDO(const ATargetTypeInfo:PTypeInfo): Boolean; overload;
    function Exists_XML(const ATargetTypeInfo:PTypeInfo): Boolean; overload;
    function Exists_Stream(const ATargetTypeInfo:PTypeInfo): Boolean; overload;
    function Exists_DOM(const ATargetClass:TClass): Boolean; overload;
    function Exists_JDO(const ATargetClass:TClass): Boolean; overload;
    function Exists_XML(const ATargetClass:TClass): Boolean; overload;
    function Exists_Stream(const ATargetClass:TClass): Boolean; overload;
    function Exists_DOM<T>: Boolean; overload;
    function Exists_JDO<T>: Boolean; overload;
    function Exists_XML<T>: Boolean; overload;
    function Exists_Stream<T>: Boolean; overload;
  end;

implementation

uses
  DJSON.Utils.RTTI, DJSON.Factory;

{ TdjParams }

constructor TdjParams.Create;
begin
  inherited;
  SetEngine(TdjEngine.eDelphiStream);
  FTypeInfoCache := TdjTypeInfoCache.Create;
  FSerializers := TdjSerializersContainer.Create;
  FTypeAnnotations := False;
  FEnableCustomSerializers := False;
  FItemsKeyDefaultQualifiedName := 'System.String';
  FItemsValueDefaultQualifiedName := '';
  FOwnJSONValue := False; // JSONValue is not owned by default
  FNameCase := ncUndefinedCase;
  FBsonRoot := True;
  FBsonRootLabel := 'root';
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

function TdjParams.GetBsonRoot: Boolean;
begin
  Result := FBsonRoot;
end;

function TdjParams.GetBsonRootLabel: String;
begin
  Result := FBsonRootLabel;
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

procedure TdjParams.SetBsonRoot(const AValue: Boolean);
begin
  FBsonRoot := AValue;
end;

procedure TdjParams.SetBsonRootLabel(const AValue: String);
begin
  FBsonRootLabel := AValue;
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

constructor TdjSerializersContainerItem.Create;
begin
  inherited Create;
  FDOMSerializer := nil;
  FJDOSerializer := nil;
  FXMLSerializer := nil;
  FStreamSerializer := nil;
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

function TdjSerializersContainer.Exists_DOM(const ATargetClass: TClass): Boolean;
begin
  Result := Self.Exists_DOM(ATargetClass.ClassInfo);
end;

function TdjSerializersContainer.Exists_DOM(
  const ATargetTypeInfo: PTypeInfo): Boolean;
begin
  Result := _Exists(ATargetTypeInfo) and Assigned(_GetSerializerItem(ATargetTypeInfo).DOMSerializer);
end;

function TdjSerializersContainer.Exists_DOM<T>: Boolean;
begin
  Result := Self.Exists_DOM(TypeInfo(T));
end;

function TdjSerializersContainer.Exists_JDO(
  const ATargetClass: TClass): Boolean;
begin
  Result := Self.Exists_JDO(ATargetClass.ClassInfo);
end;

function TdjSerializersContainer.Exists_JDO(
  const ATargetTypeInfo: PTypeInfo): Boolean;
begin
  Result := _Exists(ATargetTypeInfo) and Assigned(_GetSerializerItem(ATargetTypeInfo).JDOSerializer);
end;

function TdjSerializersContainer.Exists_JDO<T>: Boolean;
begin
  Result := Self.Exists_JDO(TypeInfo(T));
end;

function TdjSerializersContainer.Exists_Stream(
  const ATargetClass: TClass): Boolean;
begin
  Result := Self.Exists_Stream(ATargetClass.ClassInfo);
end;

function TdjSerializersContainer.Exists_Stream(
  const ATargetTypeInfo: PTypeInfo): Boolean;
begin
  Result := _Exists(ATargetTypeInfo) and Assigned(_GetSerializerItem(ATargetTypeInfo).StreamSerializer);
end;

function TdjSerializersContainer.Exists_Stream<T>: Boolean;
begin
  Result := Self.Exists_Stream(TypeInfo(T));
end;

function TdjSerializersContainer.Exists_XML(
  const ATargetClass: TClass): Boolean;
begin
  Result := Self.Exists_XML(ATargetClass.ClassInfo);
end;

function TdjSerializersContainer.Exists_XML(
  const ATargetTypeInfo: PTypeInfo): Boolean;
begin
  Result := _Exists(ATargetTypeInfo) and Assigned(_GetSerializerItem(ATargetTypeInfo).XMLSerializer);
end;

function TdjSerializersContainer.Exists_XML<T>: Boolean;
begin
  Result := Self.Exists_XML(TypeInfo(T));
end;

procedure TdjSerializersContainer.Register(const ATargetTypeInfo: PTypeInfo;
  const ASerializer: TdjDOMCustomSerializerRef);
begin
  Self._GetOrCreateSerializersContainerItem(ATargetTypeInfo).DOMSerializer := ASerializer;
end;

procedure TdjSerializersContainer.Register(const ATargetClass: TClass;
  const ASerializer: TdjDOMCustomSerializerRef);
begin
  Self.Register(ATargetClass.ClassInfo, ASerializer);
end;

procedure TdjSerializersContainer.Register<Target; Serializer>;
begin
  Self.Register(TypeInfo(Target), Serializer);
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

function TdjSerializersContainer._GetOrCreateSerializersContainerItem(
  const ATargetTypeInfo: PTypeInfo): TdjSerializersContainerItem;
begin
  if not Self._Exists(ATargetTypeInfo) then
    FSerializersContainer.Add(TdjRTTI.TypeInfoToQualifiedTypeName(ATargetTypeInfo), TdjSerializersContainerItem.Create);
  Result := Self._GetSerializerItem(ATargetTypeInfo);
end;

function TdjSerializersContainer._GetSerializerItem(
  const ATargetTypeInfo:PTypeInfo): TdjSerializersContainerItem;
begin
  Result := FSerializersContainer.Items[TdjRTTI.TypeInfoToQualifiedTypeName(ATargetTypeInfo)];
end;

procedure TdjSerializersContainer.Register(const ATargetTypeInfo: PTypeInfo;
  const ASerializer: TdjXMLCustomSerializerRef);
begin
  Self._GetOrCreateSerializersContainerItem(ATargetTypeInfo).XMLSerializer := ASerializer;
end;

procedure TdjSerializersContainer.Register(const ATargetClass: TClass;
  const ASerializer: TdjJDOCustomSerializerRef);
begin
  Self.Register(ATargetClass.ClassInfo, ASerializer);
end;

procedure TdjSerializersContainer.Register(const ATargetTypeInfo: PTypeInfo;
  const ASerializer: TdjJDOCustomSerializerRef);
begin
  Self._GetOrCreateSerializersContainerItem(ATargetTypeInfo).JDOSerializer := ASerializer;
end;

procedure TdjSerializersContainer.Register(const ATargetClass: TClass;
  const ASerializer: TdjStreamCustomSerializerRef);
begin
  Self.Register(ATargetClass.ClassInfo, ASerializer);
end;

procedure TdjSerializersContainer.Register(const ATargetTypeInfo: PTypeInfo;
  const ASerializer: TdjStreamCustomSerializerRef);
begin
  Self._GetOrCreateSerializersContainerItem(ATargetTypeInfo).StreamSerializer := ASerializer;
end;

procedure TdjSerializersContainer.Register(const ATargetClass: TClass;
  const ASerializer: TdjXMLCustomSerializerRef);
begin
  Self.Register(ATargetClass.ClassInfo, ASerializer);
end;

end.
