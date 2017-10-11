unit DJSON.Engine.Utils;

interface

uses
  System.Rtti,
  DJSON.Params;

type
  TdjEngineUtils = class
    class function GetMemberList(const AObject: TObject; const AParams: IdjParams): TArray<TRttiNamedObject>;
    class function IsSkipMember(APropField: TRttiNamedObject; const AParams: IdjParams): Boolean;
  end;

implementation

uses
  System.Generics.Collections,
  DJSON.Attributes,
  DJSON.Utils.RTTI,
  DJSON.Utils,
  DJSON.Duck.PropField;

{ TdjEngineUtils }

class function TdjEngineUtils.GetMemberList(const AObject: TObject; const AParams: IdjParams): TArray<TRttiNamedObject>;
var
  LBuffer: TList<TRttiNamedObject>;
begin
  LBuffer := TList<TRttiNamedObject>.Create;
  try
    case AParams.SerializationType of
      stProperties:
        LBuffer.AddRange(TArray<TRttiNamedObject>(TObject(TdjRTTI.TypeInfoToRttiType(AObject.ClassInfo).AsInstance.GetProperties)));
      stFields:
        LBuffer.AddRange(TArray<TRttiNamedObject>(TObject(TdjRTTI.TypeInfoToRttiType(AObject.ClassInfo).AsInstance.GetFields)));
    end;
    Result := LBuffer.ToArray;
  finally
    LBuffer.Free;
  end;

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

