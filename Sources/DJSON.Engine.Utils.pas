unit DJSON.Engine.Utils;

interface

uses
{$REGION 'System'}
  System.Rtti,
{$ENDREGION}
{$REGION 'DJSON'}
  DJSON.Params;
{$ENDREGION}

type
  TdjEngineUtils = class
    class function GetMemberList(const AObject: TObject; const AParams: IdjParams): TArray<TRttiNamedObject>;
    class function IsSkipMember(APropField: TRttiNamedObject; const AParams: IdjParams): Boolean;
    class function GetPropFieldByKey(const AKey: string; const AParams: IdjParams; AObject: TObject): TRttiNamedObject;
  end;

implementation

uses
{$REGION 'System'}
  System.Generics.Collections,
{$ENDREGION}
{$REGION 'DJSON'}
  DJSON.Attributes,
  DJSON.Utils.RTTI,
  DJSON.Utils,
  DJSON.Duck.PropField;
{$ENDREGION}

{ TdjEngineUtils }

class function TdjEngineUtils.GetMemberList(const AObject: TObject; const AParams: IdjParams): TArray<TRttiNamedObject>;
var
  LBuffer: TList<TRttiNamedObject>;
begin
  LBuffer := TList<TRttiNamedObject>.Create;
  try
    if stProperties in AParams.SerializationTypes then
      LBuffer.AddRange(TArray<TRttiNamedObject>(TObject(TdjRTTI.TypeInfoToRttiType(AObject.ClassInfo).AsInstance.GetProperties)));
    if stFields in AParams.SerializationTypes then
      LBuffer.AddRange(TArray<TRttiNamedObject>(TObject(TdjRTTI.TypeInfoToRttiType(AObject.ClassInfo).AsInstance.GetFields)));
    Result := LBuffer.ToArray;
  finally
    LBuffer.Free;
  end;
end;

class function TdjEngineUtils.GetPropFieldByKey;
var
  LNameAttribute: djNameAttribute;
  LRTTIType: TRttiInstanceType;
  LPropFieldInternal: System.Rtti.TRttiNamedObject;
  LPropsFields: TArray<System.Rtti.TRttiNamedObject>;
begin
  // Init
  LRTTIType := TdjRTTI.TypeInfoToRttiType(AObject.ClassInfo).AsInstance;
    // Get the PropField by Key
  if (stProperties in AParams.SerializationTypes) then
    Result := LRTTIType.GetProperty(AKey)
  else
    Result := LRTTIType.GetField(AKey);
    // If found then exit else continue find considering even the djNameAttribute
  if Assigned(Result) then
    Exit;
    // Get members list if not already assigned
  if not Assigned(LPropsFields) then
  begin
    LPropsFields := TdjEngineUtils.GetMemberList(AObject, AParams);
  end;
    // Loop and find
  for LPropFieldInternal in LPropsFields do
    if TdjRTTI.HasAttribute<djNameAttribute>(LPropFieldInternal, LNameAttribute) and (LNameAttribute.Name = AKey) then
    begin
      Result := LPropFieldInternal;
      Exit;
    end;
    // If not found then set the result to nil
  Result := nil;
end;

class function TdjEngineUtils.IsSkipMember(APropField: TRttiNamedObject; const AParams: IdjParams): Boolean;
begin
  Result := //
    (not Assigned(APropField)) //
    or (APropField.Name = 'FRefCount') //
    or (APropField.Name = 'RefCount')//
    or (not TdjDuckPropField.IsWritable(APropField) and (TdjDuckPropField.RttiType(APropField).TypeKind <> tkClass))   //
    or (TdjRTTI.HasAttribute<djSkipAttribute>(APropField))  //
    or TdjUtils.IsPropertyToBeIgnored(APropField, AParams);
end;

end.

