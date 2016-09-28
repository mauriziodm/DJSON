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



unit DJSON.Engine.DOM;

interface

uses
  System.JSON, System.Rtti, DJSON.Params, System.Generics.Collections;

type

  TJSONBox = TJSONObject;

  TdjEngineDOM = class
  private
    // Serializers
    class function SerializeFloat(const AValue: TValue): TJSONValue; static;
    class function SerializeEnumeration(const AValue: TValue): TJSONValue; static;
    class function SerializeInteger(const AValue: TValue): TJSONValue; static;
    class function SerializeString(const AValue: TValue): TJSONValue; static;
    class function SerializeRecord(const AValue: TValue; const APropField: TRttiNamedObject; const AParams: IdjParams): TJSONValue; static;
    class function SerializeClass(const AValue: TValue; const APropField: TRttiNamedObject; const AParams: IdjParams): TJSONValue; static;
    class function SerializeInterface(const AValue: TValue; const APropField: TRttiNamedObject; const AParams: IdjParams): TJSONValue; static;
    class function SerializeObject(const AObject: TObject; const AParams: IdjParams): TJSONBox; overload; static;
    class function SerializeObject(const AInterfacedObject: IInterface; const AParams: IdjParams): TJSONBox; overload; static;
    class function SerializeTValue(const AValue: TValue; const APropField: TRttiNamedObject; const AParams: IdjParams): TJSONValue; static;
    class function SerializeList(const AList: TObject; const APropField: TRttiNamedObject; const AParams: IdjParams; out ResultJSONValue:TJSONValue): Boolean; static;
    class function SerializeDictionary(const ADictionary: TObject; const APropField: TRttiNamedObject; const AParams: IdjParams; out ResultJSONValue:TJSONValue): Boolean; static;
    class function SerializeCustom(AValue:TValue; const APropField: TRttiNamedObject; const AParams: IdjParams; out ResultJSONValue:TJSONValue): Boolean; static;
    class function SerializeStreamableObject(const AObj: TObject; const APropField: TRttiNamedObject; out ResultJSONValue:TJSONValue): Boolean; static;
    class function SerializeStream(const AStream: TObject; const APropField: TRttiNamedObject; out ResultJSONValue:TJSONValue): Boolean; static;
    // Deserializers
    class function DeserializeFloat(const AJSONValue: TJSONValue; const AValueType: TRttiType): TValue; static;
    class function DeserializeEnumeration(const AJSONValue: TJSONValue; const AValueType: TRttiType): TValue; static;
    class function DeserializeInteger(const AJSONValue: TJSONValue): TValue; static;
    class function DeserializeString(const AJSONValue: TJSONValue): TValue; static;
    class function DeserializeRecord(const AJSONValue: TJSONValue; const AValueType: TRttiType; const APropField: TRttiNamedObject; const AParams: IdjParams): TValue; static;
    class procedure DeserializeClassCommon(var AChildObj: TObject; const AJSONValue: TJSONValue; const APropField: TRttiNamedObject; const AParams: IdjParams); static;
    class function DeserializeClass(const AJSONValue: TJSONValue; const AValueType: TRttiType; const APropField: TRttiNamedObject; AMasterObj: TObject; const AParams: IdjParams): TValue; static;
    class function DeserializeInterface(const AJSONValue: TJSONValue; const AValueType: TRttiType; const APropField: TRttiNamedObject; AMasterObj: TObject; const AParams: IdjParams): TValue; static;
    class function DeserializeObject(const AJSONBox: TJSONBox; AObject:TObject; const AParams: IdjParams): TObject; static;
    class function DeserializeTValue(const AJSONValue: TJSONValue; const APropField: TRttiNamedObject; const AParams: IdjParams): TValue; static;
    class function DeserializeList(AList: TObject; const AJSONValue: TJSONValue; const APropField: TRttiNamedObject; const AParams: IdjParams): Boolean; static;
    class function DeserializeDictionary(ADictionary: TObject; const AJSONValue: TJSONValue; const APropField: TRttiNamedObject; const AParams: IdjParams): Boolean; static;
    class function DeserializeCustom(const AJSONValue: TJSONValue; const AValueType: TRttiType; const APropField: TRttiNamedObject; const AMasterObj: TObject; const AParams: IdjParams; out ResultValue:TValue): Boolean; static;
    class function DeserializeStreamableObject(AObj: TObject; const AJSONValue: TJSONValue; const APropField: TRttiNamedObject): Boolean; static;
    class function DeserializeStream(AStream: TObject; const AJSONValue: TJSONValue; const APropField: TRttiNamedObject): Boolean; static;
  public
    class function SerializePropField(const AValue: TValue; const APropField: TRttiNamedObject; const AParams: IdjParams; const AEnableCustomSerializers:Boolean=True): TJSONValue; static;
    class function DeserializePropField(const AJSONValue: TJSONValue; const AValueType: TRttiType; const APropField: TRttiNamedObject; const AMasterObj: TObject; const AParams: IdjParams): TValue; static;
  end;

implementation

uses
  System.SysUtils, System.DateUtils, DJSON.Duck.PropField, DJSON.Utils.RTTI,
  DJSON.Exceptions, DJSON.Serializers, DJSON.Constants, DJSON.Attributes,
  DJSON.Duck.Interfaces, DJSON.Factory, DJSON.Utils, System.Classes,
  Soap.EncdDecd;

class function TdjEngineDOM.DeserializeClass(const AJSONValue: TJSONValue; const AValueType: TRttiType; const APropField: TRttiNamedObject;
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

class procedure TdjEngineDOM.DeserializeClassCommon(var AChildObj: TObject; const AJSONValue: TJSONValue;
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
  else if AJSONValue is TJSONObject then
    AChildObj := DeserializeObject(TJSONObject(AJSONValue), AChildObj, AParams)
  // If the JSONValue is a TJSONNull
  else if AJSONValue is TJSONNull then
    FreeAndNil(AChildObj)
  // Raise an exception
  else
    raise EdjEngineError.Create('Deserialize Class: Cannot deserialize as object.');
end;

class function TdjEngineDOM.DeserializeCustom(const AJSONValue: TJSONValue;
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
  LTypeJSONValue: TJSONValue;
  LJSONValue: TJSONValue;
  LObj: TObject;
  function DeserializeCustomByInternalClassMethod(const AJSONValue:TJSONValue; const AValueType:TRttiType; const AExistingValue:TValue; out ResultValue: TValue): Boolean;
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
    LMethod.Invoke(LObj, [AJSONValue]);
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
  if (AJSONValue is TJSONObject) then begin
    // Retrieve the value type if embedded in JSON
    LTypeJSONValue := TJSONObject(AJSONValue).GetValue(DJ_TYPENAME);
    if Assigned(LTypeJSONValue) then
      LValueType := TdjRTTI.QualifiedTypeNameToRttiType(LTypeJSONValue.Value);
    if not Assigned(LValueType) then
      LValueType := AValueType;
    // Retreve the JSONValue to deserializa if embedded in JSON
    LJSONValue := TJSONObject(AJSONValue).GetValue(DJ_VALUE);
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
  if Assigned(LSerializer) then
    ResultValue := LSerializer.Deserialize(
      LJSONValue,
      LExistingValue,
      LDone
      );
  // if the work has not been done by the custom serializer then
  //  call the standard serializers with custom params (if exists)
  if not LDone then
    ResultValue := DeserializePropField(LJSONValue, LValueType, APropField, AMasterObj, AParams);
end;

class function TdjEngineDOM.DeserializeDictionary(ADictionary: TObject; const AJSONValue: TJSONValue;
  const APropField: TRttiNamedObject; const AParams: IdjParams): Boolean;
var
  LDuckDictionary: IdjDuckDictionary;
  LKeyQualifiedTypeName, LValueQualifiedTypeName, LDictionaryTypeName: String;
  LKeyRttiType, LValueRTTIType: TRttiType;
  LJSONValue, LKeyJSONValue, LValueJSONValue: TJSONValue;
  LJObj: TJSONObject;
  LJSONArray: TJSONArray;
  LKey, LValue: TValue;
  I: Integer;
begin
  // Checks
  if (not Assigned(AJSONValue))
  or (AJSONValue is TJSONNull)
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
    if not (AJSONValue is TJSONObject) then
      raise EdjEngineError.Create('Wrong serialization for ' + ADictionary.QualifiedClassName);
    LJObj := AJSONValue as TJSONObject;
    // Get the Dictionary class
    LJSONValue := LJObj.GetValue(DJ_TYPENAME);
    if Assigned(LJSONValue) then
      LDictionaryTypeName := LJSONValue.Value;
    // Get the key type name
    LJSONValue := LJObj.GetValue(DJ_KEY);
    if Assigned(LJSONValue) then
      LKeyQualifiedTypeName := LJSONValue.Value;
    // Get the value type name
    LJSONValue := LJObj.GetValue(DJ_VALUE);
    if Assigned(LJSONValue) then
      LValueQualifiedTypeName := LJSONValue.Value;
    // Create the dictionary if needed
    if ADictionary = nil then // recreate  the object as it should be
      ADictionary := TdjRTTI.CreateObject(LDictionaryTypeName);
    // Get the items array
    LJSONValue := LJObj.Get('items').JsonValue;
  end
  else
    LJSONValue := AJSONValue;
  // Check and extract the JSONArray
  if not (LJSONValue is TJSONArray) then
    raise EdjEngineError.Create('Cannot restore the dictionary because the related JSONValue is not an array');
  LJSONArray := TJSONArray(LJSONValue);
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
  for I := 0 to LJSONArray.Count - 1 do
  begin
    LJObj := LJSONArray.Get(I) as TJSONObject;
    // Get the key anche value JSONValue
    case AParams.SerializationMode of
      smJavaScript:
      begin
        // Key can be any value (string, objects etc).
        LKeyJSONValue   := TJSONObject.ParseJSONValue(   LJObj.Pairs[0].JsonString.ToJSON   );
        LValueJSONValue := LJObj.Pairs[0].JsonValue;
      end;
      smDataContract:
      begin
        LKeyJSONValue   := LJObj.GetValue(DJ_KEY);
        LValueJSONValue := LJObj.GetValue(DJ_VALUE);
      end;
    end;
    // Deserialization key and value
    LKey   := DeserializePropField(LKeyJSONValue, LKeyRttiType, APropField, nil, AParams);
    LValue := DeserializePropField(LValueJSONValue, LValueRttiType, APropField, nil, AParams);
    // If the SerializationMode equals to smJavaScript then Free the LKeyJSONValue
    //  becaouse not owned by anyone
    if AParams.SerializationMode = smJavaScript then
      LKeyJSONValue.Free;
    // Add to the dictionary
    LDuckDictionary.Add(LKey, LValue);
  end;
  // If everething OK!
  Result := True;
end;

class function TdjEngineDOM.DeserializeEnumeration(const AJSONValue: TJSONValue; const AValueType: TRttiType): TValue;
begin
//  if not Assigned(AJSONValue) then   // JSONKey not present
//    raise EMapperException.Create(APropField.Name + ' key field is not present in the JSONObject');

  if AValueType.QualifiedName = 'System.Boolean' then
  begin
    if AJSONValue is TJSONTrue then
       Result := True
    else if AJSONValue is TJSONFalse then
       Result := False
    else
      raise EdjEngineError.Create('Invalid value for boolean value ');
  end
  else // it is an enumerated value but it's not a boolean.
    TValue.Make((AJSONValue as TJSONNumber).AsInt, AValueType.Handle, Result);
end;

class function TdjEngineDOM.DeserializeFloat(const AJSONValue: TJSONValue; const AValueType: TRttiType): TValue;
var
  LQualifiedTypeName: String;
begin
  if not Assigned(AJSONValue) then   // JSONKey not present
    Result := 0
  else
  begin
    LQualifiedTypeName := AValueType.QualifiedName;
    if LQualifiedTypeName = 'System.TDate' then
    begin
      if AJSONValue is TJSONNull then
        Result := 0
      else
        Result := TValue.From<TDate>(TdjUtils.ISOStrToDateTime(AJSONValue.Value + ' 00:00:00'));
    end
    else if LQualifiedTypeName = 'System.TDateTime' then
    begin
      if AJSONValue is TJSONNull then
        Result := 0
      else
        Result := TValue.From<TDateTime>(TdjUtils.ISOStrToDateTime(AJSONValue.Value));
    end
    else if LQualifiedTypeName = 'System.TTime' then
    begin
      if AJSONValue is TJSONString then
        Result := TValue.From<TTime>(TdjUtils.ISOStrToTime(AJSONValue.Value))
      else
        raise EdjEngineError.CreateFmt('Cannot deserialize TTime value, expected [%s] got [%s]',
          ['TJSONString', AJSONValue.ClassName]);
    end
    else { if APropFieldRttiType.QualifiedName = 'System.Currency' then }
    begin
      if AJSONValue is TJSONNumber then
        Result := TJSONNumber(AJSONValue).AsDouble
      else
        raise EdjEngineError.CreateFmt('Cannot deserialize float value, expected [%s] got [%s]',
          ['TJSONNumber', AJSONValue.ClassName]);
    end;
  end;
end;

class function TdjEngineDOM.DeserializeInteger(const AJSONValue: TJSONValue): TValue;
begin
  if not Assigned(AJSONValue) then  // JSONKey not present
    Result := 0
  else
    Result := StrToIntDef(AJSONValue.Value, 0);
end;

class function TdjEngineDOM.DeserializeInterface(const AJSONValue: TJSONValue; const AValueType: TRttiType;
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

class function TdjEngineDOM.DeserializeList(AList: TObject; const AJSONValue: TJSONValue; const APropField: TRttiNamedObject;
  const AParams: IdjParams): Boolean;
var
  LListTypeName, LValueQualifiedTypeName: String;
  LJSONObject: TJSONObject;
  LJSONValue, LValueJSONValue: TJSONValue;
  LJSONArray: TJSONArray;
  LValueRTTIType: TRttiType;
  LDuckList: IdjDuckList;
  I: Integer;
  LValue: TValue;
begin
  // Checks
  if (not Assigned(AJSONValue))
  or (AJSONValue is TJSONNull)
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
    if not (AJSONValue is TJSONObject) then
      raise EdjEngineError.Create('Wrong serialization for ' + AList.QualifiedClassName);
    LJSONObject := AJSONValue as TJSONObject;
    // Get the collection class
    LJSONValue := LJSONObject.GetValue(DJ_TYPENAME);
    if Assigned(LJSONValue) then
      LListTypeName := LJSONValue.Value;
    // Create the collection if needed
    if AList = nil then // recreate the object as it should be
      AList := TdjRTTI.CreateObject(LListTypeName);
    // Get the value type name
    LJSONValue := LJSONObject.GetValue(DJ_VALUE);
    if Assigned(LJSONValue) then
      LValueQualifiedTypeName := LJSONValue.Value;
    // Get the items array
    LJSONValue := LJSONObject.Get('items').JsonValue;
  end
  else
    LJSONValue := AJSONValue;
  // Check and extract the JSONArray
  if not (LJSONValue is TJSONArray) then
    raise EdjEngineError.Create('Cannot restore the list because the related JSONValue is not an array');
  LJSONArray := TJSONArray(LJSONValue);
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
    LValueJSONValue := LJSONArray.Get(I);
    // Deserialize the current element
    LValue := DeserializePropField(LValueJSONValue, LValueRttiType, APropField, nil, AParams);
    // Add to the list
    LDuckList.AddValue(LValue);
  end;
  // Se tutto è andato bene...
  Result := True;
end;

class function TdjEngineDOM.DeserializePropField(const AJSONValue: TJSONValue; const AValueType: TRttiType; const APropField: TRttiNamedObject;
  const AMasterObj: TObject; const AParams: IdjParams): TValue;
var
  LJSONValue: TJSONValue;
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
  if AValueType.Name <> 'TValue' then
  begin
    // Cerca il ValueType in una eventuale JSONAnnotation
    if AParams.TypeAnnotations and (AJSONValue is TJSONObject) then
    begin
      LJSONValue := TJSONObject(AJSONValue).GetValue(DJ_TYPENAME);
      if Assigned(LJSONValue) then
        LValueQualifiedTypeName := LJSONValue.Value;
    end;
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
      Result := DeserializeInteger(AJSONValue);
    tkFloat:
      Result := DeserializeFloat(AJSONValue, LValueType);
    tkString, tkLString, tkWString, tkUString:
      Result := DeserializeString(AJSONValue);
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

class function TdjEngineDOM.DeserializeRecord(const AJSONValue: TJSONValue;
  const AValueType: TRttiType; const APropField: TRttiNamedObject;
  const AParams: IdjParams): TValue;
var
  LQualifiedTypeName: String;
begin
  LQualifiedTypeName := AValueType.QualifiedName;
  // TTimeStamp
  if LQualifiedTypeName = 'System.SysUtils.TTimeStamp' then
  begin
    if not Assigned(AJSONValue) then  // JSONKey not present
      Result := TValue.From<TTimeStamp>(MSecsToTimeStamp(0))
    else
      Result := TValue.From<TTimeStamp>(MSecsToTimeStamp(   (AJSONValue as TJSONNumber).AsInt64   ));
  end
  // TValue
  else if LQualifiedTypeName = 'System.Rtti.TValue' then
  begin
    Result := DeserializeTValue(AJSONValue, APropField, AParams);
  end;
end;

class function TdjEngineDOM.DeserializeStream(AStream: TObject;
  const AJSONValue: TJSONValue; const APropField: TRttiNamedObject): Boolean;
var
  LStreamASString: string;
  LdsonEncodingAttribute: djEncodingAttribute;
  LEncoding: TEncoding;
  LStringStream: TStringStream;
  LStreamWriter: TStreamWriter;
begin
  // Checks
  if (not Assigned(AJSONValue))
  or (AJSONValue is TJSONNull)
  or not (Assigned(AStream) and (AStream is TStream))
  then
    Exit(False);
  // Defaults
  Result := False;
  // Get the stream as string from the JSONValue
  if AJSONValue is TJSONString then
    LStreamASString := TJSONString(AJSONValue).Value
  else
    raise EdjEngineError.Create('Deserialize Class: Expected JSONString in the received JSONValue.');
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

class function TdjEngineDOM.DeserializeStreamableObject(AObj: TObject;
  const AJSONValue: TJSONValue; const APropField: TRttiNamedObject): Boolean;
var
  LValueAsString: string;
  LStringStream: TStringStream;
  LMemoryStream: TMemoryStream;
  LDuckStreamable: IdjDuckStreamable;
begin
  // Checks
  if (not Assigned(AJSONValue))
  or (AJSONValue is TJSONNull)
  or (not TdjFactory.TryWrapAsDuckStreamable(AObj, LDuckStreamable))
  then
    Exit(False);
  // Init
  Result := False;
  LValueAsString := (AJSONValue as TJSONString).Value;
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

class function TdjEngineDOM.DeserializeString(const AJSONValue: TJSONValue): TValue;
begin
  if not Assigned(AJSONValue) then  // JSONKey not present
    Result := ''
  else
    Result := AJSONValue.Value;
end;

class function TdjEngineDOM.DeserializeTValue(const AJSONValue: TJSONValue; const APropField: TRttiNamedObject; const AParams:IdjParams): TValue;
var
  LJObj: TJSONObject;
  LValueQualifiedTypeName: String;
  LValueRTTIType: TRttiType;
  LJSONValue: TJSONValue;
//  LObj: TObject;
//  LIntf: IInterface;
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
    if not (AJSONValue is TJSONObject) then
      raise EdjEngineError.Create('Wrong serialization for TValue');
    // Extract the JSONObject from the received JSONValue
    LJObj := (AJSONValue as TJSONObject);
    // Get the value type name
    LJSONValue := LJObj.GetValue(DJ_TYPENAME);
    if Assigned(LJSONValue) then
      LValueQualifiedTypeName := LJSONValue.Value;
    // Extract the contained TValue value
    LJSONValue := LJObj.GetValue(DJ_VALUE);
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
    (LJSONValue as TJSONObject).AddPair(DJ_TYPENAME, LValueQualifiedTypeName);
  // Deserialize the value
  Result := DeserializePropField(LJSONValue, LValueRTTIType, APropField, nil, AParams);
end;

class function TdjEngineDOM.DeserializeObject(const AJSONBox: TJSONBox; AObject: TObject;
  const AParams: IdjParams): TObject;
var
  LPropField: System.Rtti.TRttiNamedObject;
  LPropsFields: TArray<System.Rtti.TRttiNamedObject>;
  LKeyName: String;
  LJSONClassName: TJSONString;
  LJSONValue: TJSONValue;
  LObjectIsValid: Boolean;
  LValue: TValue;
begin
  LObjectIsValid := Assigned(AObject);
  // If the AObject is not assigned then try to create the Object using the DMVC_ClassName value in the
  //  JSONBox
  if not LObjectIsValid then
  begin
{$IF CompilerVersion <= 26}
    if Assigned(AJSONBox.Get(DSON_TYPENAME)) then
      LJSONClassName := AJSONBox.Get(DSON_TYPENAME).JsonValue as TJSONString
    else
      raise EdsonEngineError.CreateFmt('No $s property in the JSON object', [DSON_TYPENAME]);
{$ELSE}
    if not AJSONBox.TryGetValue<TJSONString>(DJ_TYPENAME, LJSONClassName) then
      raise EdjEngineError.CreateFmt('No $s property in the JSON object', [DJ_TYPENAME]);
{$ENDIF}
    AObject := TdjRTTI.CreateObject(LJSONClassName.Value);
  end;

  LJSONValue := nil;

  try
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
      or (TdjRTTI.HasAttribute<djSkipAttribute>(LPropField))
      or (LPropField.Name = 'FRefCount')
      or (LPropField.Name = 'RefCount')
      or TdjUtils.IsPropertyToBeIgnored(LPropField, AParams)
      then
        Continue;
      // Get the JSONPair KeyName
      LKeyName := TdjUtils.GetKeyName(LPropField, AParams);
      // Check if JSONPair exists
      if Assigned(AJSONBox.Get(LKeyName)) then
        LJSONValue := AJSONBox.Get(LKeyName).JsonValue // as LJSONKeyIsNotPresent := False
      else
        LJSONValue := nil; // as LJSONKeyIsNotPresent := True
      // Deserialize the currente member and assign it to the object member
      LValue := DeserializePropField(LJSONValue, TdjDuckPropField.RttiType(LPropField), LPropField, AObject, AParams);
      if not LValue.IsEmpty then
        TdjDuckPropField.SetValue(AObject, LPropField, LValue);
    end;
    Result := AObject;
  except
    if not LObjectIsValid then
      FreeAndNil(AObject);
    raise;
  end;
end;

class function TdjEngineDOM.SerializeInterface(const AValue: TValue; const APropField: TRttiNamedObject; const AParams: IdjParams): TJSONValue;
var
  AChildInterface: IInterface;
  AChildObj: TObject;
begin
  AChildInterface := AValue.AsInterface;
  AChildObj := AChildInterface as TObject;
  Result := SerializeClass(AChildObj, APropField, AParams);
end;

class function TdjEngineDOM.SerializeList(const AList: TObject; const APropField: TRttiNamedObject; const AParams: IdjParams; out ResultJSONValue:TJSONValue): Boolean;
var
  LListTypeName, LValueQualifiedTypeName: String;
  LDuckList: IdjDuckList;
  LJSONArray: TJSONArray;
  I: Integer;
  LValue: TValue;
  LJSONValue: TJSONValue;
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
  for I := 0 to LDuckList.Count-1 do
  begin
    // Read values
    LValue := LDuckList.GetItemValue(I);
    // Serialize values
    LJSONValue := SerializePropField(LValue, APropField, AParams);
    // If first loop then add the type infos
    if AParams.TypeAnnotations and LFirst then
    begin
      LValueQualifiedTypeName := TdjRTTI.TypeInfoToQualifiedTypeName(LValue.TypeInfo);
      LFirst := False;
    end;
    // Add the current element to the JSONArray
    LJSONArray.AddElement(LJSONValue);
  end;
  // If TypeAnnotations is enabled then return a JSONObject with ClassName and a JSONArray containing the list items
  //  else return only the JSONArray containing the list items
  if AParams.TypeAnnotations then
  begin
    LResultJSONObj := TJSONObject.Create;
    LResultJSONObj.AddPair(DJ_TYPENAME, AList.QualifiedClassName);
    if not LValueQualifiedTypeName.IsEmpty then
      LResultJSONObj.AddPair(DJ_VALUE, LValueQualifiedTypeName);
    LResultJSONObj.AddPair('items', LJSONArray);
    ResultJSONValue := LResultJSONObj;
  end
  else
    ResultJSONValue := LJSONArray;
  // If everething OK!
  Result := True;
end;

class function TdjEngineDOM.SerializeClass(const AValue: TValue; const APropField: TRttiNamedObject; const AParams: IdjParams): TJSONValue;
var
  AChildObj: TObject;
begin
  // Get the child object
  AChildObj := AValue.AsObject;
  // Dictionary
  if SerializeDictionary(AChildObj, APropField, AParams, Result) then
  // List
  else if SerializeList(AChildObj, APropField, AParams, Result) then
  // Stream
  else if SerializeStream(AChildObj, APropField, Result) then
  // StreamableObject
  else if SerializeStreamableObject(AChildObj, APropField, Result) then
  // Other type of object
  else if Assigned(AChildObj) then
    Result := SerializeObject(AChildObj, AParams)
  // Object not assigned
  else
    Result := TJSONNull.Create;
end;

class function TdjEngineDOM.SerializeCustom(AValue: TValue;
  const APropField: TRttiNamedObject; const AParams: IdjParams;
  out ResultJSONValue: TJSONValue): Boolean;
var
  LSerializerItem: TdjSerializersContainerItem;
  LSerializer: TdjCustomSerializerRef;
  LMapperCustomSerializer: djSerializerAttribute;
  LJSONValue: TJSONValue;
  LJSONObj: TJSONObject;
  LParams: IdjParams;
  LDone: Boolean;
  LObj: TObject;
  function SerializeCustomByInternalClassMethod(const AValue:TValue; out ResultJSONValue: TJSONValue): Boolean;
  var
    LType: TRttiType;
    LMethod: TRttiMethod;
  begin
    Result := False;
    LType := TdjRTTI.TypeInfoToRttiType(AValue.TypeInfo);
    if not Assigned(LType) then
      Exit;
    LMethod := LType.GetMethod('ToJSON');
    if not Assigned(LMethod) then
      Exit;
    ResultJSONValue := LMethod.Invoke(AValue.AsObject, []).AsObject as TJSONValue;
    Result := True;
  end;
begin
  // Init
  Result := True;
  LDone := False;
  LSerializer := nil;
  LParams := AParams;
  // Check if CustomSerializers are enabled
  if not AParams.EnableCustomSerializers then
    Exit(False);
  // ---------- Custom serialization method in the class ----------
  // If the Value is an Interface type then convert it to real object class
  //  type implementing the interface
  if AValue.Kind = tkInterface then
  begin
    LObj := AValue.AsInterface as TObject;
    TValue.Make(@LObj, LObj.ClassInfo, AValue);
  end;
  // If the value is an object and a Serializer method is present directly in the class
  if (AValue.Kind = tkClass)
  and SerializeCustomByInternalClassMethod(AValue, LJSONValue)
  then
    LDone := True
  else
  // ---------- End: Custom serialization method in the class ----------
  // Get custom serializer if exists
  if AParams.Serializers._Exists(AValue.TypeInfo) then
  begin
    LSerializerItem := AParams.Serializers._GetSerializerItem(AValue.TypeInfo);
    LSerializer := LSerializerItem.Serializer;
    // Get the custom Params
    if Assigned(LSerializerItem.Params) then
      LParams := LSerializerItem.Params;
  end
  else
  if TdjRTTI.HasAttribute<djSerializerAttribute>(TdjRTTI.TypeInfoToRttiType(AValue.TypeInfo), LMapperCustomSerializer) then
    LSerializer := LMapperCustomSerializer.Serializer
  else
    Exit(False);
  // Serialize (if a custom serializer exists)
  if Assigned(LSerializer) then
    LJSONValue := LSerializer.Serialize(
      AValue,
      LDone
      );
  // if the work has not been done by the custom serializer then
  //  call the standard serializers with custom params (if exists)
  //  NB: Custom serializers are disabled
  if not LDone then
    LJSONValue := SerializePropField(AValue, APropField, LParams, False);
  // If DataTypeAnnotation is enabled then wrap the resutling JSONValue
  //  in a JSONObject with the type information
  if LParams.TypeAnnotations and Assigned(LSerializer) and LSerializer.isTypeNotificationCompatible then
  begin
    if LJSONValue is TJSONObject then
    begin
      LJSONObj := TJSONObject(LJSONValue);
      LJSONObj.AddPair(DJ_TYPENAME, TdjRTTI.TypeInfoToQualifiedTypeName(AValue.TypeInfo));
    end
    else
    begin
      LJSONObj := TJSONObject.Create;
      LJSONObj.AddPair(DJ_TYPENAME, TdjRTTI.TypeInfoToQualifiedTypeName(AValue.TypeInfo));
      LJSONObj.AddPair(DJ_VALUE, LJSONValue);
    end;
    ResultJSONValue := LJSONObj;
  end
  else
    ResultJSONValue := LJSONValue;
end;

class function TdjEngineDOM.SerializeDictionary(
  const ADictionary: TObject; const APropField: TRttiNamedObject; const AParams: IdjParams; out ResultJSONValue:TJSONValue): Boolean;
var
  LDuckDictionary: IdjDuckDictionary;
  LJSONArray: TJSONArray;
  LResultJSONObj, CurrJSONObj: TJSONObject;
  LJSONKey, LJSONValue: TJSONValue;
  LFirst: Boolean;
  LKey, LValue: TValue;
  LKeyQualifiedTypeName, LValueQualifiedTypeName: String;
begin
  // Wrap the dictionary in the DuckObject
  if not TdjFactory.TryWrapAsDuckDictionary(ADictionary, LDuckDictionary) then
    Exit(False);
  // Init
  LKeyQualifiedTypeName   := '';
  LValueQualifiedTypeName := '';
  // Create the Items JSON array
  LJSONArray := TJSONArray.Create;
  // Loop
  LFirst := True;
  while LDuckDictionary.MoveNext do
  begin
    // Read values
    LKey   := LDuckDictionary.GetCurrentKey;
    LValue := LDuckDictionary.GetCurrentValue;
    // Serialize values
    LJSONKey   := SerializePropField(LKey,   APropField, AParams);
    LJSONValue := SerializePropField(LValue, APropField, AParams);
    // If first loop then add the type infos
    if AParams.TypeAnnotations and LFirst then
    begin
      LKeyQualifiedTypeName   := TdjRTTI.TypeInfoToQualifiedTypeName(LKey.TypeInfo);
      LValueQualifiedTypeName := TdjRTTI.TypeInfoToQualifiedTypeName(LValue.TypeInfo);
      LFirst := False;
    end;
    // Add the current element to the JSONArray
    CurrJSONObj := TJSONObject.Create;
    case AParams.SerializationMode of
      smJavaScript:
      begin
        if LJSONKey is TJSONString then
          CurrJSONObj.AddPair(LJSONKey.Value, LJSONValue)
        else
          CurrJSONObj.AddPair(LJSONKey.ToJSON, LJSONValue);
        LJSONKey.Free; // To avoid a memory leak
      end;
      smDataContract:
      begin
        CurrJSONObj.AddPair(DJ_KEY,   LJSONKey);
        CurrJSONObj.AddPair(DJ_VALUE, LJSONValue)
      end;
    end;
    LJSONArray.AddElement(CurrJSONObj);
  end;
  // If AUseClassName is true then return a JSONObject with ClassName and a JSONArray containing the list items
  //  else return only the JSONArray containing the list items
  if AParams.TypeAnnotations then
  begin
    LResultJSONObj := TJSONObject.Create;
    LResultJSONObj.AddPair(DJ_TYPENAME, ADictionary.QualifiedClassName);
    if not LKeyQualifiedTypeName.IsEmpty then
      LResultJSONObj.AddPair(DJ_KEY, LKeyQualifiedTypeName);
    if not LValueQualifiedTypeName.IsEmpty then
      LResultJSONObj.AddPair(DJ_VALUE, LValueQualifiedTypeName);
    LResultJSONObj.AddPair('items', LJSONArray);
    ResultJSONValue := LResultJSONObj;
  end
  else
    ResultJSONValue := LJSONArray;
  // If everething OK!
  Result := True;
end;

class function TdjEngineDOM.SerializeEnumeration(const AValue: TValue): TJSONValue;
var
  LQualifiedTypeName: String;
begin
//  AQualifiedTypeName := TDuckPropField.QualifiedName(ARttiType);
  LQualifiedTypeName := TdjRTTI.TypeInfoToQualifiedTypeName(AValue.TypeInfo);
  if LQualifiedTypeName = 'System.Boolean' then
  begin
    if AValue.AsBoolean then
      Result := TJSONTrue.Create
    else
      Result := TJSONFalse.Create;
  end
  else
  begin
    Result := TJSONNumber.Create(AValue.AsOrdinal);
  end;
end;

class function TdjEngineDOM.SerializeFloat(const AValue: TValue): TJSONValue;
var
  LQualifiedTypeName: String;
begin
//  AQualifiedTypeName := TDuckPropField.QualifiedName(ARttiType);
  LQualifiedTypeName := TdjRTTI.TypeInfoToQualifiedTypeName(AValue.TypeInfo);
  if LQualifiedTypeName = 'System.TDate' then
  begin
    if AValue.AsExtended = 0 then
      Result := TJSONNull.Create
    else
      Result := TJSONString.Create(TdjUtils.ISODateToString(AValue.AsExtended))
  end
  else if LQualifiedTypeName = 'System.TDateTime' then
  begin
    if AValue.AsExtended = 0 then
      Result := TJSONNull.Create
    else
      Result := TJSONString.Create(TdjUtils.ISODateTimeToString(AValue.AsExtended))
  end
  else if LQualifiedTypeName = 'System.TTime' then
   Result := TJSONString.Create(TdjUtils.ISOTimeToString(AValue.AsExtended))
  else
    Result := TJSONNumber.Create(AValue.AsExtended);
end;

class function TdjEngineDOM.SerializeInteger(const AValue: TValue): TJSONValue;
begin
  Result := TJSONNumber.Create(AValue.AsInteger)
end;

class function TdjEngineDOM.SerializeObject(const AObject: TObject; const AParams: IdjParams): TJSONBox;
var
  LPropField: System.Rtti.TRttiNamedObject;
  LPropsFields: TArray<System.Rtti.TRttiNamedObject>;
  LKeyName: String;
  LJSONValue: TJSONValue;
  LValue: TValue;
  I: Integer;
begin
  Result := TJSONBox.Create;
  try
    // add the $dmvc.classname property to allows a strict deserialization
    if AParams.TypeAnnotations then
      Result.AddPair(DJ_TYPENAME, AObject.QualifiedClassName);
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
      if (LPropField.Name = 'FRefCount') or (LPropField.Name = 'RefCount') then Continue;
      // f := LowerCase(_property.Name);
      LKeyName := TdjUtils.GetKeyName(LPropField, AParams);
      // Check if there is properties to ignore
      if TdjUtils.IsPropertyToBeIgnored(LPropField, AParams) then
      // Check for "DoNotSerializeAttribute"
      if TdjRTTI.HasAttribute<djSkipAttribute>(LPropField) then
        Continue;
      // Serialize the currente member and add it to the JSONBox
      LValue := TdjDuckPropField.GetValue(AObject, LPropField);
      LJSONValue := SerializePropField(LValue, LPropField, AParams);
      Result.AddPair(LKeyName, LJSONValue);
    end;
  except
    FreeAndNil(Result);
    raise;
  end;
end;

class function TdjEngineDOM.SerializeObject(const AInterfacedObject: IInterface; const AParams: IdjParams): TJSONBox;
begin
  Result := SerializeObject(AInterfacedObject as TObject, AParams);
end;

class function TdjEngineDOM.SerializePropField(const AValue: TValue; const APropField: TRttiNamedObject; const AParams: IdjParams; const AEnableCustomSerializers:Boolean): TJSONValue;
begin
  // If a custom serializer exists for the current type then use it
  if AEnableCustomSerializers and AParams.EnableCustomSerializers and SerializeCustom(AValue, APropField, AParams, Result) then
    Exit;
  // Standard serialization by TypeKind
//  case TDuckPropField.TypeKind(ARttiType) of
  case AValue.Kind of
    tkInteger, tkInt64:
      Result := SerializeInteger(AValue);
    tkFloat:
      Result := SerializeFloat(AValue);
    tkString, tkLString, tkWString, tkUString:
      Result := SerializeString(AValue);
    tkEnumeration:
      Result := SerializeEnumeration(AValue);
    tkRecord:
      Result := SerializeRecord(AValue, APropField, AParams);
    tkClass:
      Result := SerializeClass(AValue, APropField, AParams);
    tkInterface:
      Result := SerializeInterface(AValue, APropField, AParams);
  end;
end;

class function TdjEngineDOM.SerializeRecord(const AValue: TValue; const APropField: TRttiNamedObject; const AParams: IdjParams): TJSONValue;
var
  ts: TTimeStamp;
  LQualifiedTypeName: String;
begin
  Result := nil;
  LQualifiedTypeName := TdjRTTI.TypeInfoToQualifiedTypeName(AValue.TypeInfo);
  // TTimeStamp
  if LQualifiedTypeName = 'System.SysUtils.TTimeStamp' then
  begin
    ts := AValue.AsType<System.SysUtils.TTimeStamp>;
    Result := TJSONNumber.Create(TimeStampToMsecs(ts));
  end
  // TValue
  else if LQualifiedTypeName = 'System.Rtti.TValue' then
  begin
    Result := SerializeTValue(AValue.AsType<TValue>, APropField, AParams);
  end;
end;

class function TdjEngineDOM.SerializeStream(const AStream: TObject;
  const APropField: TRttiNamedObject; out ResultJSONValue: TJSONValue): Boolean;
var
  LdsonEncodingAttribute: djEncodingAttribute;
  LEncoding: TEncoding;
  LStringStream: TStringStream;
begin
  // Checks
  if not (Assigned(AStream) and (AStream is TStream)) then
    Exit(False);
  // Init
  Result := False;
  // If the "dsonEncodingAtribute" is specified then use that encoding
  if TdjRTTI.HasAttribute<djEncodingAttribute>(APropField, LdsonEncodingAttribute) then
  begin
    // -------------------------------------------------------------------------
    TStream(AStream).Position := 0;
    LEncoding := TEncoding.GetEncoding(LdsonEncodingAttribute.Encoding);
    LStringStream := TStringStream.Create('', LEncoding);
    try
      LStringStream.LoadFromStream(TStream(AStream));
      ResultJSONValue := TJSONString.Create(LStringStream.DataString);
    finally
      LStringStream.Free;
    end;
    // -------------------------------------------------------------------------
  end
  // Else if the atribute is not present then serialize as base64 by default
  else
  begin
    // -------------------------------------------------------------------------
    TStream(AStream).Position := 0;
    LStringStream := TStringStream.Create;
    try
      EncodeStream(TStream(AStream), LStringStream);
      ResultJSONValue := TJSONString.Create(LStringStream.DataString);
    finally
      LStringStream.Free;
    end;
    // -------------------------------------------------------------------------
  end;
  // If everething OK!
  Result := True;
end;

class function TdjEngineDOM.SerializeStreamableObject(const AObj: TObject;
  const APropField: TRttiNamedObject; out ResultJSONValue: TJSONValue): Boolean;
var
  LDuckStreamable: IdjDuckStreamable;
  LMemoryStream: TMemoryStream;
  LStringStream: TStringStream;
begin
  // Wrap the dictionary in the DuckObject
  if not TdjFactory.TryWrapAsDuckStreamable(AObj, LDuckStreamable) then
    Exit(False);
  // Init
  Result := False;
  LMemoryStream := TMemoryStream.Create;
  LStringStream := TStringStream.Create;
  try
    LDuckStreamable.SaveToStream(LMemoryStream);
    LMemoryStream.Position := 0;
    EncodeStream(LMemoryStream, LStringStream);
    ResultJSONValue := TJSONString.Create(LStringStream.DataString);
  finally
    LMemoryStream.Free;
    LStringStream.Free;
  end;
  // If everething OK!
  Result := True;
end;

class function TdjEngineDOM.SerializeString(const AValue: TValue): TJSONValue;
begin
  Result := TJSONString.Create(AValue.AsString);
end;




class function TdjEngineDOM.SerializeTValue(const AValue: TValue; const APropField: TRttiNamedObject; const AParams: IdjParams): TJSONValue;
var
  LTypeJSONValue, LJSONValue: TJSONValue;
  JObj: TJSONObject;
  LRttiType: TRttiType;
begin
  // If the TValue is empty then return a TJSONNull and exit
  if AValue.IsEmpty then
    Exit(TJSONNull.Create);
  // Init
  LRttiType := TdjRTTI.TypeInfoToRttiType(AValue.TypeInfo);
  // Serialize the value
  LJSONValue := SerializePropField(AValue, APropField, AParams);
  // Add the qualified type name if enabled
  if AParams.TypeAnnotations then
  begin
    // Prepare an empty JSONObject;
    JObj := TJSONObject.Create;
    Result := JObj;
    // Extract the qualified type name of the value
    if (LRttiType.TypeKind = tkClass) or (LRttiType.TypeKind = tkInterface) then
      LTypeJSONValue := (LJSONValue as TJSONObject).RemovePair(DJ_TYPENAME).JsonValue
    else
      LTypeJSONValue := SerializeString(LRttiType.QualifiedName);
    // Set the TValue qualified type name
    JObj.AddPair(DJ_TYPENAME, LTypeJSONValue);
    // Set the TValue value
    JObj.AddPair(DJ_VALUE, LJSONValue);
  end
  else
    // Set the TValue value
    Result := LJSONValue;
end;

end.
