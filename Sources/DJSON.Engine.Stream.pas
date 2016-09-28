unit DJSON.Engine.Stream;

interface

uses
  System.Rtti, DJSON.Params, System.JSON.Readers;

type

  TdjEngineStream = class
  private
    // Deserializers
    class function DeserializePropField(const AJSONReader: TJSONReader; const AValueType: TRttiType; const APropField: TRttiNamedObject; const AMasterObj: TObject; const AParams: IdjParams): TValue; static;
    class function DeserializeFloat(const AJSONReader: TJSONReader; const AValueType: TRttiType): TValue; static;
    class function DeserializeEnumeration(const AJSONReader: TJSONReader; const AValueType: TRttiType): TValue; static;
    class function DeserializeInteger(const AJSONReader: TJSONReader): TValue; static;
    class function DeserializeString(const AJSONReader: TJSONReader): TValue; static;
    class function DeserializeRecord(const AJSONReader: TJSONReader; const AValueType: TRttiType; const APropField: TRttiNamedObject; const AParams: IdjParams): TValue; static;
    class procedure DeserializeClassCommon(var AChildObj: TObject; const AJSONReader: TJSONReader; const APropField: TRttiNamedObject; const AParams: IdjParams); static;
    class function DeserializeClass(const AJSONReader: TJSONReader; const AValueType: TRttiType; const APropField: TRttiNamedObject; AMasterObj: TObject; const AParams: IdjParams): TValue; static;
    class function DeserializeInterface(const AJSONReader: TJSONReader; const AValueType: TRttiType; const APropField: TRttiNamedObject; AMasterObj: TObject; const AParams: IdjParams): TValue; static;
    class procedure DeserializeObject(const AJSONReader: TJSONReader; AObject:TObject; const AParams: IdjParams); static;
    class function DeserializeTValue(const AJSONReader: TJSONReader; const APropField: TRttiNamedObject; const AParams: IdjParams): TValue; static;
    class function DeserializeList(AList: TObject; const AJSONReader: TJSONReader; const APropField: TRttiNamedObject; const AParams: IdjParams): Boolean; static;
    class function DeserializeDictionary(ADictionary: TObject; const AJSONReader: TJSONReader; const APropField: TRttiNamedObject; const AParams: IdjParams): Boolean; static;
    class function DeserializeCustom(const AJSONReader: TJSONReader; const AValueType: TRttiType; const APropField: TRttiNamedObject; const AMasterObj: TObject; const AParams: IdjParams; out ResultValue:TValue): Boolean; static;
    class function DeserializeStreamableObject(AObj: TObject; const AJSONReader: TJSONReader; const APropField: TRttiNamedObject): Boolean; static;
    class function DeserializeStream(AStream: TObject; const AJSONReader: TJSONReader; const APropField: TRttiNamedObject): Boolean; static;
    // Other
    class function TryGetTypeAnnotation(const AJSONReader: TJSONReader; const ATypeAnnotationName:String; var ResultTypeAnnotationValue:String): Boolean;
  public
    class function Deserialize(const AJSONText:String; const AValueType: TRttiType; const APropField: TRttiNamedObject; const AMasterObj: TObject; const AParams: IdjParams): TValue; static;
    class function CheckForEndObjectCharIfTypeAnnotations(const AJSONReader: TJSONReader; const AParams: IdjParams): Boolean;
  end;

implementation

uses
  System.Classes, System.SysUtils, System.JSON.Types, DJSON.Constants,
  DJSON.Duck.PropField, DJSON.Utils.RTTI, DJSON.Attributes, DJSON.Exceptions,
  DJSON.Utils, DJSON.Factory, DJSON.Duck.Interfaces, Soap.EncdDecd;

{ TdjEngineStream }

class function TdjEngineStream.CheckForEndObjectCharIfTypeAnnotations(
  const AJSONReader: TJSONReader; const AParams: IdjParams): Boolean;
begin
  Result := False;
  if AParams.TypeAnnotations then
  begin
    AJSONReader.Read;
    if AJSONReader.TokenType = TJsonToken.EndObject then
{ TODO : Risistemare }
//      AJSONReader.Read
    else
      Exit(True);
  end;
end;

class function TdjEngineStream.Deserialize(const AJSONText: String;
  const AValueType: TRttiType; const APropField: TRttiNamedObject;
  const AMasterObj: TObject; const AParams: IdjParams): TValue;
var
  LStringReader: TStringReader;
  LJSONReader: TJSONTextReader;
begin
  LStringReader := TStringReader.Create(AJSONText);
  LJSONReader := TJsonTextReader.Create(LStringReader);
  try
    if LJSONReader.Read then
      Result := DeserializePropField(LJSONReader, AValueType, APropField, AMasterObj, AParams);
  finally
    LJSONReader.Free;
    LStringReader.Free;
  end;
end;

class function TdjEngineStream.DeserializeClass(const AJSONReader: TJSONReader;
  const AValueType: TRttiType; const APropField: TRttiNamedObject;
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
  DeserializeClassCommon(LChildObj, AJSONReader, APropField, AParams);
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

class procedure TdjEngineStream.DeserializeClassCommon(var AChildObj: TObject;
  const AJSONReader: TJSONReader; const APropField: TRttiNamedObject;
  const AParams: IdjParams);
begin
  // Stream
  if DeserializeStream(AChildObj, AJSONReader, APropField) then
  // Dictionary
  else if DeserializeDictionary(AChildObj, AJSONReader, APropField, AParams) then
  // List
  else if DeserializeList(AChildObj, AJSONReader, APropField, AParams) then
  // StreamableObject
  else if DeserializeStreamableObject(AChildObj, AJSONReader, APropField) then
  // Normal object property (try to deserialize but the JSON must be a JSONObject)
  else if (AJSONReader.TokenType <> TJsonToken.Null) then
    DeserializeObject(AJSONReader, AChildObj, AParams)
  // If the JSONValue is a TJSONNull
  else if (AJSONReader.TokenType = TJsonToken.Null) then
    FreeAndNil(AChildObj)
  // Raise an exception
  else
    raise EdjEngineError.Create('Deserialize Class: Cannot deserialize as object.');
end;

class function TdjEngineStream.DeserializeCustom(const AJSONReader: TJSONReader;
  const AValueType: TRttiType; const APropField: TRttiNamedObject;
  const AMasterObj: TObject; const AParams: IdjParams;
  out ResultValue: TValue): Boolean;
var
  LObj: TObject;
  function DeserializeCustomByInternalClassMethod(const AJSONReader: TJSONReader; const AValueType:TRttiType; const AExistingValue:TValue; out ResultValue: TValue): Boolean;
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
    LMethod.Invoke(LObj, [AJSONReader]);
    Result := True;
  end;
begin

end;

class function TdjEngineStream.DeserializeDictionary(ADictionary: TObject;
  const AJSONReader: TJSONReader; const APropField: TRttiNamedObject;
  const AParams: IdjParams): Boolean;
var
  LDuckDictionary: IdjDuckDictionary;
  LKeyQualifiedTypeName, LValueQualifiedTypeName: String;
  LKeyRttiType, LValueRTTIType: TRttiType;
  LKey, LValue: TValue;
begin
  // Checks
  if not TdjFactory.TryWrapAsDuckDictionary(ADictionary, LDuckDictionary) then
    Exit(False);
  // Defaults
  Result := False;
  LKeyQualifiedTypeName   := '';
  LValueQualifiedTypeName := '';
  // If TypeAnnotations is enabled then get the "items" JSONArray containing the list items
  //  else AJSONValue is the JSONArray containing che containing the list items
  if AParams.TypeAnnotations then
  begin
    // Get the key type name (collection TypeName already retrieved by DeserializePropField)
    if not TryGetTypeAnnotation(AJSONReader, DJ_KEY, LKeyQualifiedTypeName) then
      raise EdjEngineError.Create('Key type annotation expected for ' + ADictionary.QualifiedClassName + '(TypeAnnotations enabled).');
    // Get the value type name
    if not TryGetTypeAnnotation(AJSONReader, DJ_VALUE, LValueQualifiedTypeName) then
      raise EdjEngineError.Create('Value type annotation expected for ' + ADictionary.QualifiedClassName + '(TypeAnnotations enabled).');
    // The current token must be a property name named 'items'
    if not ((AJSONReader.TokenType = TJSONToken.PropertyName) and (AJSONReader.Value.AsString = 'items')) then
      raise EdjEngineError.Create('"items" property expected for ' + ADictionary.QualifiedClassName + '(TypeAnnotations enabled).');
    AJSONReader.Read;
  end;
  // Now a JSONArray must be present
  if AJSONReader.TokenType <> TJsonToken.StartArray then
    raise EdjEngineError.Create('JSONArray expected for ' + ADictionary.QualifiedClassName);
  AJSONReader.Read;
  // Get values RttiType, if the RttiType is not found then check for
  //  "MapperItemsClassType"  or "MapperItemsType" attribute or from PARAMS
  //  PS: If the current JSONToken is EndArray then the collection is empty
  //       and then then ValueTypeChecknot is not necessary.
  TdjUtils.GetItemsTypeNameIfEmpty(APropField, AParams, LKeyQualifiedTypeName, LValueQualifiedTypeName);
  LKeyRttiType   := TdjRTTI.QualifiedTypeNameToRttiType(LKeyQualifiedTypeName);
  LValueRTTIType := TdjRTTI.QualifiedTypeNameToRttiType(LValueQualifiedTypeName);
  if AJSONReader.TokenType <> TJsonToken.EndArray then
  begin
    if not Assigned(LKeyRttiType) then
      raise EdjEngineError.Create('Key type not found deserializing ' + ADictionary.QualifiedClassName);
    if not Assigned(LValueRTTIType) then
      raise EdjEngineError.Create('Value type not found deserializing ' + ADictionary.QualifiedClassName);
  end;
  // Loop
  repeat
    // If the current JSONToken is an EndArray token then exit from the loop
    if AJSONReader.TokenType = TJSONToken.EndArray then
    begin
    { TODO : Risistemare }
//      AJSONReader.Read;
      Break;
    end;
    // Every item of the JSONDictionary must begin with a StartObject char
    if (AJSONReader.TokenType <> TJSONToken.StartObject) then
      raise EdjEngineError.Create('StartObject char expected deserializing an item of ' + ADictionary.QualifiedClassName);
    AJSONReader.Read;
    // Get the key anche value JSONValue
    case AParams.SerializationMode of
      // In this mode the property name represent the key and the value represent the value
      smJavaScript:
      begin
        // Key
        if (AJSONReader.TokenType <> TJSONToken.PropertyName) then
          raise EdjEngineError.Create('Property name expected deserializing the key of an item of ' + ADictionary.QualifiedClassName);
        LKey := DeserializePropField(AJSONReader, LKeyRttiType, APropField, nil, AParams);
        AJSONReader.Read;
        // Value
        LValue := DeserializePropField(AJSONReader, LValueRTTIType, APropField, nil, AParams);
      end;
      // In this mode there are two properties, one for the key and one for the value
      smDataContract:
      begin
        // Key
        if not((AJSONReader.TokenType = TJSONToken.PropertyName) and (AJSONReader.Value.AsString = DJ_KEY)) then
          raise EdjEngineError.Create('Property name expected deserializing the key of an item of ' + ADictionary.QualifiedClassName);
        if not AJSONReader.Read then
          raise EdjEngineError.Create('Value expected deserializing the key of an item of ' + ADictionary.QualifiedClassName);
        LKey := DeserializePropField(AJSONReader, LKeyRttiType, APropField, nil, AParams);
        AJSONReader.Read;
        // Value
        if not((AJSONReader.TokenType = TJSONToken.PropertyName) and (AJSONReader.Value.AsString = DJ_VALUE)) then
          raise EdjEngineError.Create('Property name expected deserializing the value of an item of ' + ADictionary.QualifiedClassName);
        if not AJSONReader.Read then
          raise EdjEngineError.Create('Value expected deserializing the value of an item of ' + ADictionary.QualifiedClassName);
        LValue := DeserializePropField(AJSONReader, LValueRTTIType, APropField, nil, AParams);
      end;
    end;
    // Every item of the JSONDictionary must end with a EndObject char
    if (AJSONReader.TokenType <> TJSONToken.EndObject) then
      raise EdjEngineError.Create('EndObject char expected deserializing an item of ' + ADictionary.QualifiedClassName);
    AJSONReader.Read;
    // Add to the dictionary
    LDuckDictionary.Add(LKey, LValue);
  until not AJSONReader.Read;
  // If TypeAnnotations is enabled then e "CloseObject" char is expected
  if CheckForEndObjectCharIfTypeAnnotations(AJSONReader, AParams) then
    raise EdjEngineError.Create('EndObject char expected for ' + ADictionary.QualifiedClassName + ' (TipeAnnotations enabled)');
  // Se tutto è andato bene...
  Result := True;
end;

class function TdjEngineStream.DeserializeEnumeration(
  const AJSONReader: TJSONReader; const AValueType: TRttiType): TValue;
begin
{ TODO : Controllare se è possibile assegnare AJSONReader.Value direttamente. }
  // Boolean
  if AValueType.QualifiedName = 'System.Boolean' then
    Result := AJSONReader.Value.AsBoolean
  // Other enumerated type
  else
    TValue.Make(AJSONReader.Value.AsInteger, AValueType.Handle, Result);
end;

class function TdjEngineStream.DeserializeFloat(const AJSONReader: TJSONReader;
  const AValueType: TRttiType): TValue;
var
  LQualifiedTypeName: String;
begin
  // Get the type name
  LQualifiedTypeName := AValueType.QualifiedName;
  // If Null value
  if AJSONReader.TokenType = TJsonToken.Null then
    Result := 0
  else
  // TDate (string expected)
  if (LQualifiedTypeName = 'System.TDate') and (AJSONReader.TokenType = TJsonToken.String) then
    Result := TValue.From<TDate>(TdjUtils.ISOStrToDateTime(AJSONReader.Value.AsString + ' 00:00:00'))
  else
  // TDateTime (string expected)
  if (LQualifiedTypeName = 'System.TDateTime') and (AJSONReader.TokenType = TJsonToken.String) then
    Result := TValue.From<TDateTime>(TdjUtils.ISOStrToDateTime(AJSONReader.Value.AsString))
  else
  // TTime (string expected)
  if (LQualifiedTypeName = 'System.TTime') and (AJSONReader.TokenType = TJsonToken.String) then
    Result := TValue.From<TTime>(TdjUtils.ISOStrToTime(AJSONReader.Value.AsString))
  else
  // Normal float value (Float expected)
  if (AJSONReader.TokenType = TJsonToken.Float) then
    Result := AJSONReader.Value.AsExtended
  else
  // Otherwise (raise)
    raise EdjEngineError.Create('Cannot deserialize float value.');
end;

class function TdjEngineStream.DeserializeInteger(
  const AJSONReader: TJSONReader): TValue;
begin
  case AJSONReader.TokenType of
    TJsonToken.Integer: Result := AJSONReader.Value;
  else
    raise EdjEngineError.Create('Cannot deserialize integer value.');
  end;
end;

class function TdjEngineStream.DeserializeInterface(
  const AJSONReader: TJSONReader; const AValueType: TRttiType;
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
  DeserializeClassCommon(LChildObj, AJSONReader, APropField, AParams);
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

class function TdjEngineStream.DeserializeList(AList: TObject;
  const AJSONReader: TJSONReader; const APropField: TRttiNamedObject;
  const AParams: IdjParams): Boolean;
var
  LValueQualifiedTypeName: String;
  LValueRTTIType: TRttiType;
  LDuckList: IdjDuckList;
  LValue: TValue;
begin
  // Checks
  if not TdjFactory.TryWrapAsDuckList(Alist, LDuckList) then
    Exit(False);
  // Defaults
  Result := False;
  LValueRTTIType          := nil;
  LValueQualifiedTypeName := '';
  // If TypeAnnotations is enabled then get the "items" JSONArray containing the list items
  //  else AJSONValue is the JSONArray containing che containing the list items
  if AParams.TypeAnnotations then
  begin
    // Get the value type name (collection TypeName already retrieved by DeserializePropField)
    if not TryGetTypeAnnotation(AJSONReader, DJ_VALUE, LValueQualifiedTypeName) then
      raise EdjEngineError.Create('Value type annotation expected for ' + AList.QualifiedClassName + '(TypeAnnotations enabled).');
    // The current token must be a property name named 'items'
    if not ((AJSONReader.TokenType = TJSONToken.PropertyName) and (AJSONReader.Value.AsString = 'items')) then
      raise EdjEngineError.Create('"items" property expected for ' + AList.QualifiedClassName + '(TypeAnnotations enabled).');
    AJSONReader.Read;
  end;
  // Now a JSONArray must be present
  if AJSONReader.TokenType <> TJsonToken.StartArray then
    raise EdjEngineError.Create('JSONArray expected for ' + AList.QualifiedClassName);
  AJSONReader.Read;
  // Get values RttiType, if the RttiType is not found then check for
  //  "MapperItemsClassType"  or "MapperItemsType" attribute or from PARAMS
  //  PS: If the current JSONToken is EndArray then the collection is empty
  //       and then then ValueTypeChecknot is not necessary.
  TdjUtils.GetItemsTypeNameIfEmpty(APropField, AParams, LValueQualifiedTypeName);
  LValueRTTIType := TdjRTTI.QualifiedTypeNameToRttiType(LValueQualifiedTypeName);
  if (not Assigned(LValueRTTIType)) and (AJSONReader.TokenType <> TJsonToken.EndArray) then
    raise EdjEngineError.Create('Value type not found deserializing ' + AList.QualifiedClassName);
  // Loop
  repeat
    // If the current JSONToken is an EndArray token then exit from the loop
    if (AJSONReader.TokenType = TJSONToken.EndArray) then
    begin
    { TODO : Risistemare }
//      AJSONReader.Read;
      Break;
    end;
    // Deserialize the current element
    LValue := DeserializePropField(AJSONReader, LValueRttiType, APropField, nil, AParams);
    // Add to the list
    LDuckList.AddValue(LValue);
  until not AJSONReader.Read;
  // If TypeAnnotations is enabled then e "CloseObject" char is expected
  if CheckForEndObjectCharIfTypeAnnotations(AJSONReader, AParams) then
    raise EdjEngineError.Create('EndObject char expected for ' + AList.QualifiedClassName + '(TypeAnnotations enabled).');
  // Se tutto è andato bene...
  Result := True;
end;


class procedure TdjEngineStream.DeserializeObject(const AJSONReader: TJSONReader;
  AObject: TObject; const AParams: IdjParams);
var
  LPropFieldKey: String;
  LPropsFields: TArray<System.Rtti.TRttiNamedObject>;
  LPropField: System.Rtti.TRttiNamedObject;
  LRTTIType: TRTTIInstanceType;
  LValue: TValue;
  procedure GetPropFieldByKey;
  var
    LNameAttribute: djNameAttribute;
    LPropFieldInternal: System.Rtti.TRttiNamedObject;
  begin
    // Get the PropField by Key
    case AParams.SerializationType of
      stProperties: LPropField := LRTTIType.GetProperty(LPropFieldKey);
      stFields: LPropField := LRTTIType.GetField(LPropFieldKey);
    end;
    // If found then exit else continue find considering even the djNameAttribute
    if Assigned(LPropField) then Exit;
    // Get members list if not alreadi assigned
    if not Assigned(LPropsFields) then
    begin
      case AParams.SerializationType of
        stProperties:
          LPropsFields := TArray<System.Rtti.TRttiNamedObject>(TObject(TdjRTTI.TypeInfoToRttiType(AObject.ClassInfo).AsInstance.GetProperties));
        stFields:
          LPropsFields := TArray<System.Rtti.TRttiNamedObject>(TObject(TdjRTTI.TypeInfoToRttiType(AObject.ClassInfo).AsInstance.GetFields));
      end;
    end;
    // Loop and find
    for LPropFieldInternal in LPropsFields do
      if TdjRTTI.HasAttribute(LPropFieldInternal, LNameAttribute) and (LNameAttribute.Name = LPropFieldKey) then
      begin
        LPropField := LPropFieldInternal;
        Exit;
      end;
    // If not found then set the result to nil
    LPropField := nil;
  end;
begin
  // Init
  LRTTIType := TdjRTTI.TypeInfoToRttiType(AObject.ClassInfo).AsInstance;
  // Loop for all JSONTokens (all properties of the object)
  repeat
    // If the current JSONToken is an EndObject token then exit from the loop
    if (AJSONReader.TokenType = TJSONToken.EndObject) then
    begin
{ TODO : Riststemare }
//      AJSONReader.Read;
      Break;
    end;
    // The current token must be a property name
    if (AJSONReader.TokenType <> TJSONToken.PropertyName) then
      raise EdjEngineError.Create('DeserializeObject: PropertyName token type expected.');
    // Get the current prop/field name
    LPropFieldKey := AJSONReader.Value.AsString;
    AJSONReader.Read;
    // Get the PropField by Key
    GetPropFieldByKey;
    // Check to continue or not
    if (not Assigned(LPropField))
    or (not TdjDuckPropField.IsWritable(LPropField) and (TdjDuckPropField.RttiType(LPropField).TypeKind <> tkClass))
    or (TdjRTTI.HasAttribute<djSkipAttribute>(LPropField))
    or (LPropField.Name = 'FRefCount')
    or (LPropField.Name = 'RefCount')
    or TdjUtils.IsPropertyToBeIgnored(LPropField, AParams)
    then
      Continue;
    // Deserialize the currente member and assign it to the object member
    LValue := DeserializePropField(AJSONReader, TdjDuckPropField.RttiType(LPropField), LPropField, AObject, AParams);
    if not LValue.IsEmpty then
      TdjDuckPropField.SetValue(AObject, LPropField, LValue);
  until (not AJSONReader.Read);
end;

class function TdjEngineStream.DeserializePropField(
  const AJSONReader: TJSONReader; const AValueType: TRttiType;
  const APropField: TRttiNamedObject; const AMasterObj: TObject;
  const AParams: IdjParams): TValue;
var
  LValueQualifiedTypeName: String;
  LValueType: TRttiType;
  LdsonTypeAttribute: djTypeAttribute;
begin
  // Init
  Result := TValue.Empty;
  // If the current token is a "StartObject" the move to the next token...
  if (AJSONReader.TokenType = TJsonToken.StartObject) then
     AJSONReader.Read;
  // ---------------------------------------------------------------------------
  // Determina il ValueType del valore/oggetto corrente
  //  NB: If TypeAnnotations is enabled and a TypeAnnotation is present in the AJSONValue for the current
  //  value/object then load and use it as AValueType
  //  NB: Ho aggiunto questa parte perchè altrimenti in caso di una lista di interfacce (es: TList<IPerson>)
  //  NB. Se alla fine del blocco non trova un ValueTypeValido allora usa quello ricevuto come parametro
  LValueType := nil;
  LValueQualifiedTypeName := String.Empty;
  // Non deve considerare i TValue
  if AValueType.Name <> 'TValue' then
  begin
    // Cerca il ValueType in una eventuale JSONAnnotation e se non la trova
    //  cerca anche un eventuale attributo LValueQualifiedTypeName
    if not TryGetTypeAnnotation(AJSONReader, DJ_TYPENAME, LValueQualifiedTypeName) then
      if Assigned(APropField)
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

{ TODO : Riattivare custom serializers }
  // If a custom serializer exists for the current type then use it
//  if DeserializeCustom(AJSONValue, LValueType, APropField, AMasterObj, AParams, Result) then
//    Exit;

{ TODO : Controllare se è possibile assegnare AJSONReader.Value direttamente per più tipi possibile }
  // Deserialize by TypeKind
  case LValueType.TypeKind of
    tkEnumeration:
      Result := DeserializeEnumeration(AJSONReader, LValueType);
    tkInteger, tkInt64:
      Result := DeserializeInteger(AJSONReader);
    tkFloat:
      Result := AJSONReader.Value.AsExtended;
    tkString, tkLString, tkWString, tkUString:
      Result := DeserializeString(AJSONReader);
    tkRecord:
      Result := DeserializeRecord(AJSONReader, LValueType, APropField, AParams);
    tkClass:
      Result := DeserializeClass(
        AJSONReader,
        LValueType,
        APropField,
        AMasterObj,
        AParams
        );
    tkInterface:
      Result := DeserializeInterface(
        AJSONReader,
        LValueType,
        APropField,
        AMasterObj,
        AParams
        );
  end;
end;

class function TdjEngineStream.DeserializeRecord(const AJSONReader: TJSONReader;
  const AValueType: TRttiType; const APropField: TRttiNamedObject;
  const AParams: IdjParams): TValue;
var
  LQualifiedTypeName: String;
begin
  LQualifiedTypeName := AValueType.QualifiedName;
  // TTimeStamp
  if LQualifiedTypeName = 'System.SysUtils.TTimeStamp' then
  begin
    if AJSONReader.TokenType = TJsonToken.Null then
      Result := TValue.From<TTimeStamp>(MSecsToTimeStamp(0))
    else
      Result := TValue.From<TTimeStamp>(MSecsToTimeStamp(   AJSONReader.Value.AsInt64   ));
  end
  // TValue
  else if LQualifiedTypeName = 'System.Rtti.TValue' then
  begin
    Result := DeserializeTValue(AJSONReader, APropField, AParams);
  end;
end;

class function TdjEngineStream.DeserializeStream(AStream: TObject;
  const AJSONReader: TJSONReader; const APropField: TRttiNamedObject): Boolean;
var
  LStreamASString: string;
  LdsonEncodingAttribute: djEncodingAttribute;
  LEncoding: TEncoding;
  LStringStream: TStringStream;
  LStreamWriter: TStreamWriter;
begin
  // Checks
  if not (Assigned(AStream) and (AStream is TStream)) then
    Exit(False);
  // Defaults
  Result := False;
  // The JSONToken must be a string type
  if not(AJSONReader.TokenType <> TJsonToken.String) then
    raise EdjEngineError.Create('Wrong JSON token type deserializing a stream.');
  // Load the string representation of the stream from the JSON then
  //  load it into the object
  LStreamASString := AJSONReader.Value.AsString;
  AJSONReader.Read;
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

class function TdjEngineStream.DeserializeStreamableObject(AObj: TObject;
  const AJSONReader: TJSONReader; const APropField: TRttiNamedObject): Boolean;
var
  LDuckStreamable: IdjDuckStreamable;
  LValueAsString: string;
  LStringStream: TStringStream;
  LMemoryStream: TMemoryStream;
begin
  // Checks
  if not TdjFactory.TryWrapAsDuckStreamable(AObj, LDuckStreamable) then
    Exit(False);
  // Init
  Result := False;
  // The JSONToken must be a string type
  if not(AJSONReader.TokenType <> TJsonToken.String) then
    raise EdjEngineError.Create('Wrong JSON token type deserializing a streamable object (' + AObj.ClassName + ')');
  // Load the string representation of the stream from the JSON then
  //  load it into the object
  LValueAsString := AJSONReader.Value.AsString;
  AJSONReader.Read;
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

class function TdjEngineStream.DeserializeString(
  const AJSONReader: TJSONReader): TValue;
begin
 Result := AJSONReader.Value;

{ TODO : Risistemare }
//  case AJSONReader.TokenType of
//    TJsonToken.String: Result := AJSONReader.Value;
//  else
//    raise EdjEngineError.Create('Cannot deserialize string value.');
//  end;
end;

class function TdjEngineStream.DeserializeTValue(const AJSONReader: TJSONReader;
  const APropField: TRttiNamedObject; const AParams: IdjParams): TValue;
var
  LValueQualifiedTypeName: string;
  LValueRTTIType: TRttiType;
begin
  // Defaults
  LValueQualifiedTypeName := '';
  // If TypeAnnotations is enabled then get the "items" JSONArray containing the list items
  //  else AJSONValue is the JSONArray containing che containing the list items
  if AParams.TypeAnnotations then
  begin
    // Get the value type name (collection TypeName already retrieved by DeserializePropField)
    if not TryGetTypeAnnotation(AJSONReader, DJ_TYPENAME, LValueQualifiedTypeName) then
      raise EdjEngineError.Create('Value type annotation expected for TValue (TypeAnnotations enabled).');
    // The current token must be a property name named "DJ_VALUE" (it is a constant)
    if not ((AJSONReader.TokenType = TJSONToken.PropertyName) and (AJSONReader.Value.AsString = DJ_VALUE)) then
      raise EdjEngineError.Create('DJ_VALUE (constant) property expected for TValue (TypeAnnotations enabled).');
    AJSONReader.Read;
  end;
  // Get values RttiType, if the RttiType is not found then check for
  //  "dsonType" attribute
  TdjUtils.GetTypeNameIfEmpty(APropField, AParams, LValueQualifiedTypeName);
  LValueRTTIType := TdjRTTI.QualifiedTypeNameToRttiType(LValueQualifiedTypeName);
  if not Assigned(LValueRTTIType) then
    raise EdjEngineError.Create('Value type not found deserializing a TValue');
  // Deserialize the value
  Result := DeserializePropField(AJSONReader, LValueRTTIType, APropField, nil, AParams);
  // If TypeAnnotations is enabled then e "CloseObject" char is expected
  if CheckForEndObjectCharIfTypeAnnotations(AJSONReader, AParams) then
    raise EdjEngineError.Create('EndObject char expected for TValue (TypeAnnotations enabled).');
end;

class function TdjEngineStream.TryGetTypeAnnotation(
  const AJSONReader: TJSONReader; const ATypeAnnotationName: String;
  var ResultTypeAnnotationValue: String): Boolean;
begin
  Result := False;
  if (AJSONReader.TokenType = TJsonToken.PropertyName) and (AJSONReader.Value.AsString = ATypeAnnotationName) then
  begin
    if not AJSONReader.Read then
      raise EdjEngineError.Create('Value expected deserializing a type annotation (' + ATypeAnnotationName + ')');
    ResultTypeAnnotationValue := AJSONReader.Value.AsString;
    AJSONReader.Read;
    Result := True;
  end;
end;

end.
