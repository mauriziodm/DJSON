unit DJSON.Engine.JDO;

interface

uses
  JsonDataObjects, System.Rtti, DJSON.Params;

type

  TJSONBox = TJSONObject;

  TdjEngineJDO = class
  private
    // Serializers
    class procedure SerializePropField(const AResult:PJsonDataValue; const AValue: TValue; const APropField: TRttiNamedObject; const AParams: IdjParams; const AEnableCustomSerializers:Boolean=True); static;
    class procedure SerializeFloat(const AResult:PJsonDataValue; const AValue: TValue); static;
    class procedure SerializeEnumeration(const AResult:PJsonDataValue; const AValue: TValue); static;
    class procedure SerializeRecord(const AResult:PJsonDataValue; const AValue: TValue; const APropField: TRttiNamedObject; const AParams: IdjParams); static;
    class procedure SerializeClass(const AResult:PJsonDataValue; const AValue: TValue; const APropField: TRttiNamedObject; const AParams: IdjParams); static;
    class procedure SerializeInterface(const AResult:PJsonDataValue; const AValue: TValue; const APropField: TRttiNamedObject; const AParams: IdjParams); static;
    class function SerializeObject(const AObject: TObject; const AParams: IdjParams): TJSONBox; overload; static;
    class function SerializeObject(const AInterfacedObject: IInterface; const AParams: IdjParams): TJSONBox; overload; static;
    class procedure SerializeTValue(const AResult:PJsonDataValue; const AValue: TValue; const APropField: TRttiNamedObject; const AParams: IdjParams); static;
    class function SerializeList(const AResult:PJsonDataValue; const AList: TObject; const APropField: TRttiNamedObject; const AParams: IdjParams): Boolean; static;
    class function SerializeDictionary(const AResult:PJsonDataValue; const ADictionary: TObject; const APropField: TRttiNamedObject; const AParams: IdjParams): Boolean; static;
    class function SerializeCustom(AValue:TValue; const APropField: TRttiNamedObject; const AParams: IdjParams; out ResultJSONValue:PJsonDataValue): Boolean; static;
    class function SerializeStreamableObject(const AObj: TObject; const APropField: TRttiNamedObject; out ResultJSONValue:PJsonDataValue): Boolean; static;
    class function SerializeStream(const AStream: TObject; const APropField: TRttiNamedObject; out ResultJSONValue:PJsonDataValue): Boolean; static;
    // Deserializers
    class function DeserializePropField(const AJSONValue: PJsonDataValue; const AValueType: TRttiType; const APropField: TRttiNamedObject; const AMasterObj: TObject; const AParams: IdjParams): TValue; static;
    class function DeserializeFloat(const AJSONValue: PJsonDataValue; const AValueType: TRttiType): TValue; static;
    class function DeserializeEnumeration(const AJSONValue: PJsonDataValue; const AValueType: TRttiType): TValue; static;
    class function DeserializeRecord(const AJSONValue: PJsonDataValue; const AValueType: TRttiType; const APropField: TRttiNamedObject; const AParams: IdjParams): TValue; static;
    class procedure DeserializeClassCommon(var AChildObj: TObject; const AJSONValue: PJsonDataValue; const APropField: TRttiNamedObject; const AParams: IdjParams); static;
    class function DeserializeClass(const AJSONValue: PJsonDataValue; const AValueType: TRttiType; const APropField: TRttiNamedObject; AMasterObj: TObject; const AParams: IdjParams): TValue; static;
    class function DeserializeInterface(const AJSONValue: PJsonDataValue; const AValueType: TRttiType; const APropField: TRttiNamedObject; AMasterObj: TObject; const AParams: IdjParams): TValue; static;
    class function DeserializeObject(const AJSONBox: TJSONBox; AObject:TObject; const AParams: IdjParams): TObject; static;
    class function DeserializeTValue(const AJSONValue: PJsonDataValue; const APropField: TRttiNamedObject; const AParams: IdjParams): TValue; static;
    class function DeserializeList(AList: TObject; const AJSONValue: PJsonDataValue; const APropField: TRttiNamedObject; const AParams: IdjParams): Boolean; static;
    class function DeserializeDictionary(ADictionary: TObject; const AJSONValue: PJsonDataValue; const APropField: TRttiNamedObject; const AParams: IdjParams): Boolean; static;
    class function DeserializeCustom(const AJSONValue: PJsonDataValue; const AValueType: TRttiType; const APropField: TRttiNamedObject; const AMasterObj: TObject; const AParams: IdjParams; out ResultValue:TValue): Boolean; static;
    class function DeserializeStreamableObject(AObj: TObject; const AJSONValue: PJsonDataValue; const APropField: TRttiNamedObject): Boolean; static;
    class function DeserializeStream(AStream: TObject; const AJSONValue: PJsonDataValue; const APropField: TRttiNamedObject): Boolean; static;
  public
    class function Serialize(const AValue: TValue; const APropField: TRttiNamedObject; const AParams: IdjParams; const AEnableCustomSerializers:Boolean=True): String; static;
    class function Deserialize(const AJSONText:String; const AValueType: TRttiType; const APropField: TRttiNamedObject; const AMasterObj: TObject; const AParams: IdjParams): TValue; static;
  end;

implementation

uses
  DJSON.Duck.PropField, DJSON.Utils.RTTI, System.SysUtils, DJSON.Exceptions,
  DJSON.Serializers, DJSON.Attributes, DJSON.Constants, DJSON.Duck.Interfaces,
  DJSON.Factory, DJSON.Utils, System.Classes, Soap.EncdDecd;

class function TdjEngineJDO.Deserialize(const AJSONText: String;
  const AValueType: TRttiType; const APropField: TRttiNamedObject;
  const AMasterObj: TObject; const AParams: IdjParams): TValue;
var
  LTmpJSONArray: TJsonArray;
  LJSONValue: PJsonDataValue;
begin
  //  NB: Non ho trovato un modo per generare un JSONValue singolo che non sia
  //       all'interno di un JSONObject oppure JSONArray, per cui faccio fare
  //       il Parse forzatamente su un JSONArray e poi ne prelevo il JSONValue contenuto.
  LTmpJSONArray := TJSONArray(TJSONArray.Parse(   '['+AJSONText+']'   ));
  try
    LJSONValue   := LTmpJSONArray.Items[0];
    Result := DeserializePropField(LJSONValue, AValueType, APropField, AMasterObj, AParams);
  finally
    LTmpJSONArray.Free;
  end;
end;

class function TdjEngineJDO.DeserializeClass(const AJSONValue: PJsonDataValue; const AValueType: TRttiType; const APropField: TRttiNamedObject;
  AMasterObj: TObject; const AParams: IdjParams): TValue;
var
  LChildObj: TObject;
begin
  // Init
  LChildObj := nil;
  // If the Property/Field is valid then try to get the value (Object) from the
  //  master object else the MasterObject itself is the destination of the deserialization
  if Assigned(AMasterObj) then
    if TdjDuckPropField.IsValidPropField(APropField) then
      LChildObj := TdjRTTI.TValueToObject(   TdjDuckPropField.GetValue(AMasterObj, APropField)   )
    else
      LChildObj := AMasterObj;
  // If the LChildObj is not assigned and the AValueType is assigned then
  //  create the LChildObj of the type specified by the AValueType parameter,
  //  PS: normally used by DeserializeList or other collection deserialization
  if Assigned(AValueType) and (not Assigned(LChildObj)) then // and (not AParams.TypeAnnotations) then
    LChildObj := TdjRTTI.CreateObject(AValueType.QualifiedName);
  // Deserialize
  DeserializeClassCommon(LChildObj, AJSONValue, APropField, AParams);
  // Make the result TValue
  //  NB: If the MasterObj is assigned return an empty TValue because if the
  //       deserialized object is a detail of a MasterObject the creation of the
  //       child object is responsibility of the Master object itself, so the
  //       child object is already assigned to the master object property.
  if Assigned(AMasterObj) then
    Result := TValue.Empty
  else
    TValue.Make(@LChildObj, LChildObj.ClassInfo, Result);
end;

class procedure TdjEngineJDO.DeserializeClassCommon(var AChildObj: TObject; const AJSONValue: PJsonDataValue;
  const APropField: TRttiNamedObject; const AParams: IdjParams);
begin
  // Check JSONValue
  if not Assigned(AJSONValue) then
    Exit;
  // Stream
  if DeserializeStream(AChildObj, AJSONValue, APropField) then
  // Dictionary
  else if DeserializeDictionary(AChildObj, AJSONValue, APropField, AParams) then
  // List
  else if DeserializeList(AChildObj, AJSONValue, APropField, AParams) then
  // StreamableObject
  else if DeserializeStreamableObject(AChildObj, AJSONValue, APropField) then
  // Normal object property (try to deserialize but the JSON must be a JSONObject)
  else if AJSONValue.Typ = TJsonDataType.jdtObject then
    AChildObj := DeserializeObject(AJSONValue.ObjectValue, AChildObj, AParams)
  // If the JSONValue is a TJSONNull
  else if (AJSONValue.Typ = TJsonDataType.jdtNone) then
    FreeAndNil(AChildObj)
  // Raise an exception
  else
    raise EdjEngineError.Create('Deserialize Class: Cannot deserialize as object.');
end;

class function TdjEngineJDO.DeserializeCustom(const AJSONValue: PJsonDataValue;
  const AValueType: TRttiType; const APropField: TRttiNamedObject;
  const AMasterObj: TObject; const AParams: IdjParams;
  out ResultValue: TValue): Boolean;
var
  LSerializerItem: TdjSerializersContainerItem;
  LSerializer: TdjCustomSerializerRef;
  LMapperCustomSerializer: djSerializerAttribute;
  LParams: IdjParams;
  LDone: Boolean;
  LValueType: TRttiType;
  LJSONObj: TJSONObject;
  LQualifiedName: String;
  LExistingValue: TValue;
  LValueTypeName: String;
  LJSONValue: PJsonDataValue;
  LObj: TObject;
  function DeserializeCustomByInternalClassMethod(const AJSONValue:TJSONDataValueHelper; const AValueType:TRttiType; const AExistingValue:TValue; out ResultValue: TValue): Boolean;
  var
    LMethod: TRttiMethod;
    LObj: TObject;
  begin
    Result := False;
    LMethod := AValueType.GetMethod('FromJSON');
    if not Assigned(LMethod) then
      Exit;
    if AExistingValue.IsEmpty then
    begin
      LObj := TdjRTTI.CreateObject(AValueType.QualifiedName);
      TValue.Make(@LObj, LObj.ClassInfo, ResultValue);
    end
    else
    begin
      LObj := AExistingValue.AsObject;
      ResultValue := AExistingValue;
    end;
    LMethod.Invoke(LObj, [TValue.From<TJSONDataValueHelper>(AJSONValue)]);
    Result := True;
  end;
begin
  // Init
  Result := True;
  LDone := False;
  LQualifiedName := '';
  LSerializer := nil;
  LExistingValue := nil;
  LParams := AParams;
  // Check if CustomSerializers are enabled
  if not AParams.EnableCustomSerializers then
    Exit(False);
  // If the Property/Field is valid then try to get the value (Object) from the
  //  master object else the MasterObject itself is the destination of the deserialization
  if Assigned(AMasterObj) then
    if TdjDuckPropField.IsValidPropField(APropField) then
      LExistingValue := TdjDuckPropField.GetValue(AMasterObj, APropField)
    else
      TValue.Make(@AMasterObj, AMasterObj.ClassInfo, LExistingValue);
  // Check if a value type is embedded in the JSON and extract it (if exists)
  //  else use the received value type.
  //  If the value type is embedded in the JSON (TypeAnnotations = True) then extract
  //   then contained value too as JSONValue and pass it to the custom serializer
  LValueType := AValueType;
  LJSONValue := AJSONValue;
  if (AJSONValue.Typ = TJsonDataType.jdtObject) then
  begin
    LJSONObj := AJSONValue.ObjectValue;
    // Retrieve the value type if embedded in JSON
    LValueTypeName := LJSONObj.S[DJ_TYPENAME];
    if not LValueTypeName.IsEmpty then
      LValueType := TdjRTTI.QualifiedTypeNameToRttiType(LValueTypeName)
    else
      LValueType := AValueType;
    // Retrieve the JSONValue to deserializa if embedded in JSON
    if LJSONObj.Contains(DJ_VALUE) then
      LJSONValue := LJSONObj.Items[LJSONObj.IndexOf(DJ_VALUE)];
  end;
  // ---------- Custom serialization method in the class ----------
  // If the Value is an Interface type then convert it to real object class
  //  type implementing the interface
  if (LValueType.TypeKind = tkInterface) and not LExistingValue.IsEmpty then
  begin
    LObj := LExistingValue.AsInterface as TObject;
    TValue.Make(@LObj, LObj.ClassInfo, LExistingValue);
  end;
  // If the value is an object and a Serializer method is present directly in the class
  if (LValueType.TypeKind = tkClass)
  and DeserializeCustomByInternalClassMethod(LJSONValue, LValueType, LExistingValue, ResultValue)
  then
    LDone := True
  else
  // ---------- End: Custom serialization method in the class ----------
  // Get custom serializer if exists
  if AParams.Serializers._Exists(LValueType.Handle) then
  begin
    LSerializerItem := AParams.Serializers._GetSerializerItem(LValueType.Handle);
    LSerializer := LSerializerItem.Serializer;
    // Get the custom Params
    if Assigned(LSerializerItem.Params) then
      LParams := LSerializerItem.Params;
  end
  else
  if TdjRTTI.HasAttribute<djSerializerAttribute>(TdjRTTI.TypeInfoToRttiType(LValueType.Handle), LMapperCustomSerializer) then
    LSerializer := LMapperCustomSerializer.Serializer
  else
    Exit(False);
  // Serialize (if a custom serializer exists)
{ TODO : ELiminato per il momento }
//  if Assigned(LSerializer) then
//    ResultValue := LSerializer.Deserialize(
//      LJSONValue,
//      LExistingValue,
//      LDone
//      );
  // if the work has not been done by the custom serializer then
  //  call the standard serializers with custom params (if exists)
  if not LDone then
    ResultValue := DeserializePropField(LJSONValue, LValueType, APropField, AMasterObj, AParams);
end;

class function TdjEngineJDO.DeserializeDictionary(ADictionary: TObject; const AJSONValue: PJsonDataValue;
  const APropField: TRttiNamedObject; const AParams: IdjParams): Boolean;
var
  LDuckDictionary: IdjDuckDictionary;
  LKeyQualifiedTypeName, LValueQualifiedTypeName, LDictionaryTypeName: String;
  LKeyRttiType, LValueRTTIType: TRttiType;
  LJSONValue, LKeyJSONValue, LValueJSONValue: PJsonDataValue;
  LJObj: TJSONObject;
  LJSONArray, LTmpKeyJSONArray: TJSONArray;
  LKey, LValue: TValue;
begin
  // Checks
  if (not Assigned(AJSONValue))
  or (AJSONValue.Typ = TJsonDataType.jdtNone)
  or (not TdjFactory.TryWrapAsDuckDictionary(ADictionary, LDuckDictionary))
  then
    Exit(False);
  // Defaults
  Result := False;
  LDictionaryTypeName     := '';
  LKeyQualifiedTypeName   := '';
  LValueQualifiedTypeName := '';
  // If AUseClassName is true then get the "items" JSONArray containing che containing the list items
  //  else AJSONValue is the JSONArray containing che containing the list items
  if AParams.TypeAnnotations then
  begin
    if AJSONValue.Typ <> TJsonDataType.jdtObject then
      raise EdjEngineError.Create('Wrong serialization for ' + ADictionary.QualifiedClassName);
    LJObj := AJSONValue.ObjectValue;
    // Get the Dictionary, Key and Value type names
    LDictionaryTypeName := LJObj.S[DJ_TYPENAME];
    LKeyQualifiedTypeName := LJObj.S[DJ_KEY];
    LValueQualifiedTypeName := LJObj.S[DJ_VALUE];
    // Get the items array
    LJSONValue := LJObj.Items[LJObj.IndexOf('items')];
  end
  else
    LJSONValue := AJSONValue;
  // Check and extract the JSONArray
  if LJSONValue.Typ <> TJsonDataType.jdtArray then
    raise EdjEngineError.Create('Cannot restore the dictionary because the related JSONValue is not an array');
  LJSONArray := LJSONValue.ArrayValue;
  // Get values RttiType, if the RttiType is not found then check for dsonTypeAttribute
  TdjUtils.GetItemsTypeNameIfEmpty(APropField, AParams, LKeyQualifiedTypeName, LValueQualifiedTypeName);
  LKeyRttiType   := TdjRTTI.QualifiedTypeNameToRttiType(LKeyQualifiedTypeName);
  LValueRTTIType := TdjRTTI.QualifiedTypeNameToRttiType(LValueQualifiedTypeName);
  if LJSONArray.Count > 0 then
  begin
    if not Assigned(LKeyRttiType) then
      raise EdjEngineError.Create('Key type not found deserializing a Dictionary');
    if not Assigned(LValueRTTIType) then
      raise EdjEngineError.Create('Value type not found deserializing a Dictionary');
  end;
  // Loop
  for LJObj in LJSONArray do
  begin
    // Get the key anche value JSONValue
    case AParams.SerializationMode of
      smJavaScript:
      begin
        // Key can be any value (string, objects etc).
        //  NB: Non ho trovato un modo per generare un JSONValue singolo che non sia
        //       all'interno di un JSONObject oppure JSONArray, per cui faccio fare
        //       il Parse forzatamente su un JSONArray e poi ne prelevo il JSONValue contenuto.
        LTmpKeyJSONArray := TJSONArray(TJSONArray.Parse(   '['+LJObj.Names[0]+']'   ));
        LKeyJSONValue   := LTmpKeyJSONArray.Items[0];
        LValueJSONValue := LJObj.Items[0];
      end;
      smDataContract:
      begin
        LKeyJSONValue   := LJObj.Items[LJObj.IndexOf(DJ_KEY)];
        LValueJSONValue   := LJObj.Items[LJObj.IndexOf(DJ_VALUE)];
      end;
    end;
    // Deserialization key and value
    LKey   := DeserializePropField(LKeyJSONValue, LKeyRttiType, APropField, nil, AParams);
    LValue := DeserializePropField(LValueJSONValue, LValueRttiType, APropField, nil, AParams);
    // If the SerializationMode equals to smJavaScript then Free the LKeyJSONValue
    //  becaouse not owned by anyone
    if AParams.SerializationMode = smJavaScript then
      LTmpKeyJSONArray.Free;
    // Add to the dictionary
    LDuckDictionary.Add(LKey, LValue);
  end;
  // If everething OK!
  Result := True;
end;

class function TdjEngineJDO.DeserializeEnumeration(const AJSONValue: PJsonDataValue; const AValueType: TRttiType): TValue;
begin
  if AValueType.QualifiedName = 'System.Boolean' then
  begin
    if AJSONValue.Typ = TJsonDataType.jdtBool then
      Result := AJSONValue.BoolValue
    else
      raise EdjEngineError.Create('Invalid value for boolean value ');
  end
  else // it is an enumerated value but it's not a boolean.
    TValue.Make(AJSONValue.IntValue, AValueType.Handle, Result);
end;

class function TdjEngineJDO.DeserializeFloat(const AJSONValue: PJsonDataValue; const AValueType: TRttiType): TValue;
var
  LQualifiedTypeName: String;
begin
  // Get the type name
  LQualifiedTypeName := AValueType.QualifiedName;
  // If JSONValue not assigned or NULL
  if (not Assigned(AJSONValue)) or (AJSONValue.Typ = TJsonDataType.jdtNone) then
     Exit(0);
  // TDate (string expected)
  if (LQualifiedTypeName = 'System.TDate') then
    Exit(   TValue.From<TDate>(AJSONValue.DateTimeValue)   );
  // TDateTime (string expected)
  if (LQualifiedTypeName = 'System.TDateTime') then
    Exit(   TValue.From<TDateTime>(AJSONValue.DateTimeValue)   );
  // TTime (string expected)
  if (LQualifiedTypeName = 'System.TTime') then
    Exit(   TValue.From<TTime>(AJSONValue.DateTimeValue)   );
  // Normal float value (Float expected)
  if (AJSONValue.Typ = TJsonDataType.jdtFloat) then
    Exit(AJSONValue.FloatValue);
  // Otherwise (raise)
  raise EdjEngineError.Create('Cannot deserialize float value.');
end;

class function TdjEngineJDO.DeserializeInterface(const AJSONValue: PJsonDataValue; const AValueType: TRttiType;
  const APropField: TRttiNamedObject; AMasterObj: TObject;
  const AParams: IdjParams): TValue;
var
  LChildObj: TObject;
begin
  // Init
  LChildObj := nil;
  // If the Property/Field is valid then try to get the value (Object) from the
  //  master object else the MasterObject itself is the destination of the deserialization
  if Assigned(AMasterObj) then
    if TdjDuckPropField.IsValidPropField(APropField) then
      LChildObj := TdjRTTI.TValueToObject(TdjDuckPropField.GetValue(AMasterObj, APropField))
    else
      LChildObj := AMasterObj;
  // If the LChildObj is not assigned and the AValueType is assigned then
  //  create the LChildObj of the type specified by the AValueType parameter,
  //  PS: normally used by DeserializeList or other collection deserialization
  if Assigned(AValueType) and (not Assigned(LChildObj)) and (not AParams.TypeAnnotations) then
    LChildObj := TdjRTTI.CreateObject(AValueType.QualifiedName);
  // Deserialize
  DeserializeClassCommon(LChildObj, AJSONValue, APropField, AParams);
  // Make the result TValue
  //  NB: If the MasterObj is assigned return an empty TValue because if the
  //       deserialized object is a detail of a MasterObject the creation of the
  //       child object is responsibility of the Master object itself, so the
  //       child object is already assigned to the master object property.
  if Assigned(AMasterObj) then
    Result := TValue.Empty
  else
    TValue.Make(@LChildObj, LChildObj.ClassInfo, Result);
end;

class function TdjEngineJDO.DeserializeList(AList: TObject; const AJSONValue: PJsonDataValue; const APropField: TRttiNamedObject;
  const AParams: IdjParams): Boolean;
var
  LListTypeName, LValueQualifiedTypeName: String;
  LJSONObject: TJSONObject;
  LJSONValue, LValueJSONValue: PJsonDataValue;
  LJSONArray: TJSONArray;
  LValueRTTIType: TRttiType;
  LDuckList: IdjDuckList;
  LValue: TValue;
  I: Integer;
begin
  // Checks
  if (not Assigned(AJSONValue))
  or (AJSONValue.Typ = TJsonDataType.jdtNone)
  or (not TdjFactory.TryWrapAsDuckList(Alist, LDuckList))
  then
    Exit(False);
  // Defaults
  Result := False;
  LValueRTTIType          := nil;
  LListTypeName           := '';
  LValueQualifiedTypeName := '';
  // If AUseClassName is true then get the "items" JSONArray containing che containing the list items
  //  else AJSONValue is the JSONArray containing che containing the list items
  if AParams.TypeAnnotations then
  begin
    if AJSONValue.Typ <> TJsonDataType.jdtObject then
      raise EdjEngineError.Create('Wrong serialization for ' + AList.QualifiedClassName);
    LJSONObject := AJSONValue.ObjectValue;
    // Get the collection anche the value type name
    LListTypeName := LJSONObject.S[DJ_TYPENAME];
    LValueQualifiedTypeName := LJSONObject.S[DJ_VALUE];
    // Get the items array
    LJSONValue := LJSONObject.Items[LJSONObject.IndexOf('items')];
  end
  else
    LJSONValue := AJSONValue;
  // Check and extract the JSONArray
  if LJSONValue.Typ <> TJsonDataType.jdtArray then
    raise EdjEngineError.Create('Cannot restore the list because the related JSONValue is not an array');
  LJSONArray := LJSONValue.ArrayValue;
  // Get values RttiType, if the RttiType is not found then check for
  //  "MapperItemsClassType"  or "MapperItemsType" attribute or from PARAMS
  TdjUtils.GetItemsTypeNameIfEmpty(APropField, AParams, LValueQualifiedTypeName);
  LValueRTTIType := TdjRTTI.QualifiedTypeNameToRttiType(LValueQualifiedTypeName);
  if (not Assigned(LValueRTTIType)) and (LJSONArray.Count > 0) then
    raise EdjEngineError.Create('Value type not found deserializing a List');
  // Loop
  for I := 0 to LJSONArray.Count - 1 do
  begin
    // Extract the current element
    LValueJSONValue := LJSONArray.Items[I];
    // Deserialize the current element
    LValue := DeserializePropField(LValueJSONValue, LValueRttiType, APropField, nil, AParams);
    // Add to the list
    LDuckList.AddValue(LValue);
  end;
  // Se tutto è andato bene...
  Result := True;
end;

class function TdjEngineJDO.DeserializePropField(const AJSONValue: PJsonDataValue; const AValueType: TRttiType; const APropField: TRttiNamedObject;
  const AMasterObj: TObject; const AParams: IdjParams): TValue;
var
  LValueQualifiedTypeName: String;
  LValueType: TRttiType;
  LdsonTypeAttribute: djTypeAttribute;
begin
  // Init
  Result := TValue.Empty;
  // ---------------------------------------------------------------------------
  // Determina il ValueType del valore/oggetto corrente
  //  NB: If TypeAnnotations is enabled and a TypeAnnotation is present in the AJSONValue for the current
  //  value/object then load and use it as AValueType
  //  NB: Ho aggiunto questa parte perchè altrimenti in caso di una lista di interfacce (es: TList<IPerson>)
  //  NB. Se alla fine del blocco non trova un ValueTypeValido allora usa quello ricevuto come parametro
  LValueType := nil;
  LValueQualifiedTypeName := String.Empty;
  // Non deve considerare i TValue
  if not(   Assigned(AValueType) and (AValueType.Name = 'TValue')   ) then
  begin
    // Cerca il ValueType in una eventuale JSONAnnotation
    if AParams.TypeAnnotations and (AJSONValue.Typ = TJsonDataType.jdtObject) then
      LValueQualifiedTypeName := AJSONValue.ObjectValue.S[DJ_TYPENAME];
    // Se ancora non è stato determinato il ValueType prova anche a vedere se  stato specificato
    //  l'attributo dsonTypeAttribute
    if LValueQualifiedTypeName.IsEmpty and Assigned(APropField)
    and (TdjDuckPropField.QualifiedName(APropField) = AValueType.QualifiedName)  // Questo per evitare che nel caso delle liste anche le items vedano l'attributo dsonTypeAttribute della proprietà a cui ri riferisce la lista stessa
    and TdjRTTI.HasAttribute<djTypeAttribute>(APropField, LdsonTypeAttribute)
    then
      LValueQualifiedTypeName := LdsonTypeAttribute.QualifiedName;
  end;
  //  NB. Se alla fine del blocco non trova un ValueTypeValido allora usa quello ricevuto come parametro
  if LValueQualifiedTypeName.IsEmpty then
    LValueType := AValueType
  else
    LValueType := TdjRTTI.QualifiedTypeNameToRttiType(LValueQualifiedTypeName);
  // ---------------------------------------------------------------------------
  // If a custom serializer exists for the current type then use it
  if DeserializeCustom(AJSONValue, LValueType, APropField, AMasterObj, AParams, Result) then
    Exit;
  // Deserialize by TypeKind
  case LValueType.TypeKind of
    tkEnumeration:
      Result := DeserializeEnumeration(AJSONValue, LValueType);
    tkInteger, tkInt64:
      Result := AJSONValue.IntValue;
    tkFloat:
      Result := DeserializeFloat(AJSONValue, LValueType);
    tkString, tkLString, tkWString, tkUString:
      Result := AJSONValue.Value;
    tkRecord:
      Result := DeserializeRecord(AJSONValue, LValueType, APropField, AParams);
    tkClass:
      Result := DeserializeClass(
        AJSONValue,
        LValueType,
        APropField,
        AMasterObj,
        AParams
        );
    tkInterface:
      Result := DeserializeInterface(
        AJSONValue,
        LValueType,
        APropField,
        AMasterObj,
        AParams
        );
  end;
end;

class function TdjEngineJDO.DeserializeRecord(const AJSONValue: PJsonDataValue;
  const AValueType: TRttiType; const APropField: TRttiNamedObject;
  const AParams: IdjParams): TValue;
var
  LQualifiedTypeName: String;
begin
  // Get the type name
  LQualifiedTypeName := AValueType.QualifiedName;
  // TDate (integer expected)
  if (LQualifiedTypeName = 'SSystem.SysUtils.TTimeStamp') then
    Exit(   TValue.From<TTimeStamp>(MSecsToTimeStamp(AJSONValue.IntValue))   );
  // TValue
  if LQualifiedTypeName = 'System.Rtti.TValue' then
    Exit(   DeserializeTValue(AJSONValue, APropField, AParams)   );
end;

class function TdjEngineJDO.DeserializeStream(AStream: TObject;
  const AJSONValue: PJsonDataValue; const APropField: TRttiNamedObject): Boolean;
var
  LStreamASString: string;
  LdsonEncodingAttribute: djEncodingAttribute;
  LEncoding: TEncoding;
  LStringStream: TStringStream;
  LStreamWriter: TStreamWriter;
begin
  // Checks
  if (not Assigned(AJSONValue))
  or (AJSONValue.Typ = TJsonDataType.jdtNone)
  or not (Assigned(AStream) and (AStream is TStream))
  then
    Exit(False);
  // Defaults
  Result := False;
  // Get the stream as string from the JSONValue
  if AJSONValue.Typ <> TJsonDataType.jdtString then
    raise EdjEngineError.Create('Deserialize stream: JSONString expected.');
  LStreamASString := AJSONValue.Value;
  // If the "dsonEncodingAtribute" is specified then use that encoding
  if TdjRTTI.HasAttribute<djEncodingAttribute>(APropField, LdsonEncodingAttribute) then
  begin
    // -------------------------------------------------------------------------
    TStream(AStream).Position := 0;
    LEncoding := TEncoding.GetEncoding(LdsonEncodingAttribute.Encoding);
    LStringStream := TStringStream.Create(LStreamASString, LEncoding);
    try
      LStringStream.Position := 0;
      TStream(AStream).CopyFrom(LStringStream, LStringStream.Size);
    finally
      LStringStream.Free;
    end;
    // -------------------------------------------------------------------------
  end
  // Else if the atribute is not present then deserialize as base64 by default
  else
  begin
    // -------------------------------------------------------------------------
    TStream(AStream).Position := 0;
    LStreamWriter := TStreamWriter.Create(TStream(AStream));
    try
      LStreamWriter.Write(DecodeString(LStreamASString));
    finally
      LStreamWriter.Free;
    end;
    // -------------------------------------------------------------------------
  end;
  // If everething OK!
  Result := True;
end;

class function TdjEngineJDO.DeserializeStreamableObject(AObj: TObject;
  const AJSONValue: PJsonDataValue; const APropField: TRttiNamedObject): Boolean;
var
  LValueAsString: string;
  LStringStream: TStringStream;
  LMemoryStream: TMemoryStream;
  LDuckStreamable: IdjDuckStreamable;
begin
  // Checks
  if (not Assigned(AJSONValue))
  or (AJSONValue.Typ = TJsonDataType.jdtNone)
  or (not TdjFactory.TryWrapAsDuckStreamable(AObj, LDuckStreamable))
  then
    Exit(False);
  // Init
  Result := False;
  LValueAsString := AJSONValue.Value;
  LStringStream := TSTringStream.Create;
  LMemoryStream := TMemoryStream.Create;
  try
    LStringStream.WriteString(LValueAsString);
    LStringStream.Position := 0;
    DecodeStream(LStringStream, LMemoryStream);
    LMemoryStream.Position := 0;
    LDuckStreamable.LoadFromStream(LMemoryStream);
  finally
    LMemoryStream.Free;
    LStringStream.Free;
  end;
  // Se tutto è andato bene...
  Result := True;
end;

class function TdjEngineJDO.DeserializeTValue(const AJSONValue: PJsonDataValue; const APropField: TRttiNamedObject; const AParams:IdjParams): TValue;
var
  LJObj: TJSONObject;
  LValueQualifiedTypeName: String;
  LValueRTTIType: TRttiType;
  LJSONValue: PJsonDataValue;
begin
  // Defaults
  LValueQualifiedTypeName := '';
  // If JSONValue not assigned
  if not Assigned(AJSONValue) then
    Exit(TValue.Empty);
  // If TypeAnnotations is true then get the "items" JSONArray containing che containing the list items
  //  else AJSONValue is the JSONArray containing che containing the list items
  if AParams.TypeAnnotations then
  begin
    if (AJSONValue.Typ <> TJsonDataType.jdtObject) then
      raise EdjEngineError.Create('Wrong serialization for TValue');
    // Extract the JSONObject from the received JSONValue
    LJObj := AJSONValue.ObjectValue;
    // Get the value type name
    LValueQualifiedTypeName := LJObj.S[DJ_TYPENAME];
    // Extract the contained TValue value
    LJSONValue := LJObj.Items[LJObj.IndexOf(DJ_VALUE)];
  end
  else
    LJSONValue := AJSONValue;
  // Get values RttiType, if the RttiType is not found then check for
  //  "dsonType" attribute
  TdjUtils.GetTypeNameIfEmpty(APropField, AParams, LValueQualifiedTypeName);
  LValueRTTIType := TdjRTTI.QualifiedTypeNameToRttiType(LValueQualifiedTypeName);
  if not Assigned(LValueRTTIType) then
    raise EdjEngineError.Create('Value type not found deserializing a TValue');
  // Durante la serializzazione del TVAlue, se questo conteneva un oggetto/interfaccia
  //  il serializzatore lo ha serializzato con il parametro "AUSeClassName = False" perchè
  //  siccome la serializzazione del TValue inserisce anch'essa il QualifiedTypeName del
  //  valore si sarebbe venuto a creare un doppione.
  //  Per questo motivo ora inietto il QualifiedTypeName dell'oggetto da deserializzare
  //  (se si tratta di un oggetto) nel JSONObject come se fosse stato originariamente inserito
  //  dal "SerializeObject" in modo che il "DeserializeObject" lo possa trovare e utilizzare.
  if  AParams.TypeAnnotations
  and (   (LValueRTTIType.TypeKind = tkClass) or (LValueRTTIType.TypeKind = tkInterface)   )
  then
    LJSONValue.ObjectValue.S[DJ_TYPENAME] := LValueQualifiedTypeName;
  // Deserialize the value
  Result := DeserializePropField(LJSONValue, LValueRTTIType, APropField, nil, AParams);
end;

class function TdjEngineJDO.Serialize(const AValue: TValue;
  const APropField: TRttiNamedObject; const AParams: IdjParams;
  const AEnableCustomSerializers: Boolean): String;
var
  LJSONValue: TJsonDataValue;
begin
  SerializePropField(@LJSONValue, AValue, APropField, AParams, AEnableCustomSerializers);
  case LJSONValue.Typ of
    TJsonDataType.jdtObject:
    begin
      Result := LJSONValue.ObjectValue.ToJSON(True);
      LJSONValue.ObjectValue.Free;
    end;
    TJsonDataType.jdtArray:
    begin
      Result := LJSONValue.ArrayValue.ToJSON(True);
      LJSONValue.ArrayValue.Free;
    end
  else
    Result := LJSONValue.Value;
  end;
end;

class procedure TdjEngineJDO.SerializeClass(const AResult:PJsonDataValue; const AValue: TValue;
  const APropField: TRttiNamedObject; const AParams: IdjParams);
var
  AChildObj: TObject;
begin
  // Get the child object
  AChildObj := AValue.AsObject;
  // Dictionary
//  if SerializeDictionary(AChildObj, APropField, AParams, Result) then
  // List
  if SerializeList(AResult, AChildObj, APropField, AParams) then
  // Stream
//  else if SerializeStream(AChildObj, APropField, Result) then
  // StreamableObject
//  else if SerializeStreamableObject(AChildObj, APropField, Result) then
  // Other type of object
  else if Assigned(AChildObj) then
    AResult.ObjectValue := SerializeObject(AChildObj, AParams);
  // Object not assigned
//  else;
end;

class function TdjEngineJDO.SerializeCustom(AValue: TValue;
  const APropField: TRttiNamedObject; const AParams: IdjParams;
  out ResultJSONValue: PJsonDataValue): Boolean;
begin

end;

class function TdjEngineJDO.SerializeDictionary(const AResult:PJsonDataValue; const ADictionary: TObject;
  const APropField: TRttiNamedObject; const AParams: IdjParams): Boolean;
begin

end;

class procedure TdjEngineJDO.SerializeEnumeration(const AResult:PJsonDataValue;
  const AValue: TValue);
var
  LQualifiedTypeName: String;
begin
  // Get the type name
  LQualifiedTypeName := TdjRTTI.TypeInfoToQualifiedTypeName(AValue.TypeInfo);
  // Boolean
  if LQualifiedTypeName = 'System.Boolean' then
    AResult.BoolValue := AValue.AsBoolean
  // Other enumeration
  else
    AResult.IntValue := AValue.AsOrdinal;
end;

class procedure TdjEngineJDO.SerializeFloat(const AResult:PJsonDataValue;
  const AValue: TValue);
var
  LQualifiedTypeName: String;
begin
  // Get the type name
  LQualifiedTypeName := TdjRTTI.TypeInfoToQualifiedTypeName(AValue.TypeInfo);
  // TDate
  if LQualifiedTypeName = 'System.TDate' then
  begin
    if AValue.AsExtended <> 0 then
      AResult.Value := TdjUtils.ISODateToString(AValue.AsExtended);
  end
  // TDateTime
  else if LQualifiedTypeName = 'System.TDateTime' then
  begin
    if AValue.AsExtended <> 0 then
      AResult.Value := TdjUtils.ISODateTimeToString(AValue.AsExtended);
  end
  // TTime
  else if LQualifiedTypeName = 'System.TTime' then
   AResult.Value := TdjUtils.ISOTimeToString(AValue.AsExtended)
  // Float
  else
   AResult.FloatValue := AValue.AsExtended;
end;

class procedure TdjEngineJDO.SerializeInterface(const AResult:PJsonDataValue; const AValue: TValue;
  const APropField: TRttiNamedObject; const AParams: IdjParams);
var
  AChildInterface: IInterface;
  AChildObj: TObject;
begin
  AChildInterface := AValue.AsInterface;
  AChildObj := AChildInterface as TObject;
  SerializeClass(AResult, AChildObj, APropField, AParams);
end;

class function TdjEngineJDO.SerializeList(const AResult:PJsonDataValue; const AList: TObject;
  const APropField: TRttiNamedObject; const AParams: IdjParams): Boolean;
var
  LListTypeName, LValueQualifiedTypeName: String;
  LDuckList: IdjDuckList;
  LJSONArray: TJSONArray;
  I: Integer;
  LValue: TValue;
  LJSONValue: PJsonDataValue;
  LFirst: Boolean;
  LResultJSONObj: TJSONObject;
begin
  // Wrap the dictionary in the DuckObject
  if not TdjFactory.TryWrapAsDuckList(Alist, LDuckList) then
    Exit(False);
  // Init
  Result := False;
  LListTypeName           := '';
  LValueQualifiedTypeName := '';
  // Create the Items JSON array
  LJSONArray := TJSONArray.Create;
  // Loop for all objects in the list (now compatible with interfaces)
  LFirst := True;
  LJSONArray.Count := LDuckList.Count;
  for I := 0 to LDuckList.Count-1 do
  begin
    // Read values
    LValue := LDuckList.GetItemValue(I);
    // Create the new PJsonDataValue
    LJSONValue := LJSONArray.Items[I];
    // Serialize values
    SerializePropField(LJSONValue, LValue, APropField, AParams);
    // If first loop then add the type infos
    if AParams.TypeAnnotations and LFirst then
    begin
      LValueQualifiedTypeName := TdjRTTI.TypeInfoToQualifiedTypeName(LValue.TypeInfo);
      LFirst := False;
    end;
  end;
  // If TypeAnnotations is enabled then return a JSONObject with ClassName and a JSONArray containing the list items
  //  else return only the JSONArray containing the list items
  if AParams.TypeAnnotations then
  begin
    LResultJSONObj := TJSONObject.Create;
    LResultJSONObj.S[DJ_TYPENAME] := AList.QualifiedClassName;
    if not LValueQualifiedTypeName.IsEmpty then
      LResultJSONObj.S[DJ_VALUE] := LValueQualifiedTypeName;
    LResultJSONObj.A['items'] := LJSONArray;
    AResult.ObjectValue := LResultJSONObj;
  end
  else
    AResult.ArrayValue := LJSONArray;
  // If everething OK!
  Result := True;
end;

class function TdjEngineJDO.SerializeObject(const AInterfacedObject: IInterface;
  const AParams: IdjParams): TJSONBox;
begin
  Result := SerializeObject(AInterfacedObject as TObject, AParams);
end;

class procedure TdjEngineJDO.SerializePropField(const AResult:PJsonDataValue; const AValue: TValue;
  const APropField: TRttiNamedObject; const AParams: IdjParams;
  const AEnableCustomSerializers: Boolean);
begin
  // If a custom serializer exists for the current type then use it
//  if AEnableCustomSerializers and AParams.EnableCustomSerializers and SerializeCustom(AValue, APropField, AParams, Result) then
//    Exit;
  // Standard serialization by TypeKind
  case AValue.Kind of
    tkInteger, tkInt64:
      AResult.IntValue := AValue.AsInteger;
//    tkFloat:
//      Result := SerializeFloat(AValue);
    tkString, tkLString, tkWString, tkUString:
      AResult.Value := AValue.AsString;
//    tkEnumeration:
//      Result := SerializeEnumeration(AValue);
//    tkRecord:
//      Result := SerializeRecord(AValue, APropField, AParams);
    tkClass:
      SerializeClass(AResult, AValue, APropField, AParams);
//    tkInterface:
//      Result := SerializeInterface(AValue, APropField, AParams);
  end;
end;

class function TdjEngineJDO.SerializeObject(const AObject: TObject;
  const AParams: IdjParams): TJSONBox;
var
  LPropField: System.Rtti.TRttiNamedObject;
  LPropsFields: TArray<System.Rtti.TRttiNamedObject>;
  LKeyName: String;
  LJSONValue: PJsonDataValue;
  LValue: TValue;
  I: Integer;
begin
  Result := TJSONBox.Create;
  try
    // add the $dmvc.classname property to allows a strict deserialization
    if AParams.TypeAnnotations then
      Result.S[DJ_TYPENAME] := AObject.QualifiedClassName;
    // Get members list
    case AParams.SerializationType of
      stProperties:
        LPropsFields := TArray<System.Rtti.TRttiNamedObject>(TObject(TdjRTTI.TypeInfoToRttiType(AObject.ClassInfo).AsInstance.GetProperties));
      stFields:
        LPropsFields := TArray<System.Rtti.TRttiNamedObject>(TObject(TdjRTTI.TypeInfoToRttiType(AObject.ClassInfo).AsInstance.GetFields));
    end;
    // Loop for all members
    for LPropField in LPropsFields do
    begin
      // Skip the RefCount
      if (LPropField.Name = 'FRefCount')
      or (LPropField.Name = 'RefCount')
      or TdjUtils.IsPropertyToBeIgnored(LPropField, AParams)
      or TdjRTTI.HasAttribute<djSkipAttribute>(LPropField)
      then
        Continue;
      // Get the KeyName
      LKeyName := TdjUtils.GetKeyName(LPropField, AParams);
      // Get the current property value
      LValue := TdjDuckPropField.GetValue(AObject, LPropField);
      // Get the key
      Result[LKeyName] := nil;
      // Create/Get the JSONValue
      LJSONValue := Result.Items[Result.IndexOf(LKeyName)];
      // Serialize the current property
      SerializePropField(LJSONValue, LValue, LPropField, AParams);
    end;
  except
    FreeAndNil(Result);
    raise;
  end;
end;

class function TdjEngineJDO.DeserializeObject(const AJSONBox: TJSONBox; AObject: TObject;
  const AParams: IdjParams): TObject;
var
  LJSONValue: PJsonDataValue;
  LPropField: System.Rtti.TRttiNamedObject;
  LPropsFields: TArray<System.Rtti.TRttiNamedObject>;
  LKeyName: String;
  LValue: TValue;
begin
  LJSONValue := nil;
  // Get members list
  case AParams.SerializationType of
    stProperties:
      LPropsFields := TArray<System.Rtti.TRttiNamedObject>(TObject(TdjRTTI.TypeInfoToRttiType(AObject.ClassInfo).AsInstance.GetProperties));
    stFields:
      LPropsFields := TArray<System.Rtti.TRttiNamedObject>(TObject(TdjRTTI.TypeInfoToRttiType(AObject.ClassInfo).AsInstance.GetFields));
  end;
  // Loop for all members
  for LPropField in LPropsFields do
  begin
    // Check to continue or not
    if (not TdjDuckPropField.IsWritable(LPropField) and (TdjDuckPropField.RttiType(LPropField).TypeKind <> tkClass))
    or (LPropField.Name = 'FRefCount')
    or (LPropField.Name = 'RefCount')
    or TdjUtils.IsPropertyToBeIgnored(LPropField, AParams)
    or (TdjRTTI.HasAttribute<djSkipAttribute>(LPropField))
    then
      Continue;
    // Get the JSONPair KeyName
    LKeyName := TdjUtils.GetKeyName(LPropField, AParams);
    // Check if JSONPair exists
    if AJSONBox.Contains(LKeyName) then
      LJSONValue := AJSONBox.Items[AJSONBox.IndexOf(LKeyName)]
    else
      LJSONValue := nil;
    // Deserialize the currente member and assign it to the object member
    LValue := DeserializePropField(LJSONValue, TdjDuckPropField.RttiType(LPropField), LPropField, AObject, AParams);
    if not LValue.IsEmpty then
      TdjDuckPropField.SetValue(AObject, LPropField, LValue);
  end;
  Result := AObject;
end;


class procedure TdjEngineJDO.SerializeRecord(const AResult:PJsonDataValue; const AValue: TValue;
  const APropField: TRttiNamedObject; const AParams: IdjParams);
var
  LQualifiedTypeName: String;
  LTimeStamp: TTimeStamp;
begin
  // Get the type name
  LQualifiedTypeName := TdjRTTI.TypeInfoToQualifiedTypeName(AValue.TypeInfo);
  // TimeStamp
  if LQualifiedTypeName = 'System.SysUtils.TTimeStamp' then
  begin
    LTimeStamp := AValue.AsType<System.SysUtils.TTimeStamp>;
    AResult.FloatValue := TimeStampToMsecs(LTimeStamp);
  end
  // TValue
  else if LQualifiedTypeName = 'System.Rtti.TValue' then
  begin
    SerializeTValue(AResult, AValue.AsType<TValue>, APropField, AParams);
  end;
end;

class function TdjEngineJDO.SerializeStream(const AStream: TObject;
  const APropField: TRttiNamedObject;
  out ResultJSONValue: PJsonDataValue): Boolean;
begin

end;

class function TdjEngineJDO.SerializeStreamableObject(const AObj: TObject;
  const APropField: TRttiNamedObject;
  out ResultJSONValue: PJsonDataValue): Boolean;
begin

end;

class procedure TdjEngineJDO.SerializeTValue(const AResult:PJsonDataValue; const AValue: TValue;
  const APropField: TRttiNamedObject; const AParams: IdjParams);
var
  LJSONObject: TJSONObject;
  LTypeJSONValue, LJSONValue: PJsonDataValue;
  LRttiType: TRttiType;
begin
  // If the TValue is empty then return a TJSONNull and exit
  if AValue.IsEmpty then
    Exit;
  // Init
  LRttiType := TdjRTTI.TypeInfoToRttiType(AValue.TypeInfo);
  // Add the qualified type name if enabled
  if AParams.TypeAnnotations then
  begin
    // Prepare an empty JSONObject;
    LJSONObject := TJSONObject.Create;
    AResult.ObjectValue := LJSONObject;
    // Create a new JSONValue for the type name
    LTypeJSONValue := LJSONObject.Items[LJSONObject.IndexOf(DJ_TYPENAME)];
    // Create a new JSONValue for the value
    LJSONValue := LJSONObject.Items[LJSONObject.IndexOf(DJ_VALUE)];
    // Deserialize the value
    SerializePropField(LJSONValue, AValue, APropField, AParams);
    // Extract the qualified type name of the value
    if (LRttiType.TypeKind = tkClass) or (LRttiType.TypeKind = tkInterface) then
    begin
      LTypeJSONValue.Value := LJSONValue.ObjectValue.S[DJ_TYPENAME];
      LJSONValue.ObjectValue.Remove(DJ_TYPENAME);
    end
    else
      LTypeJSONValue.Value := LRttiType.QualifiedName;
  end
  // else if TypeAnnotations disabled...
  else
    SerializePropField(AResult, AValue, APropField, AParams);
end;

end.
