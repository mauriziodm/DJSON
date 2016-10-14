unit DJSON.Engine.Stream.BSON;

interface

uses
  DJSON.Engine.Stream, System.Rtti, DJSON.Params, System.Classes;

type

  TdjEngineStreamBSON = class(TdjEngineStream)
  public
    class function Serialize(const AValue: TValue; const APropField: TRttiNamedObject; const AParams: IdjParams; const AEnableCustomSerializers:Boolean=True): TBytesStream; static;
    class function Deserialize(const AByteStream:TStream; const AValueType: TRttiType; const APropField: TRttiNamedObject; const AMasterObj: TObject; const AParams: IdjParams): TValue; static;
  end;

implementation

uses
  System.JSON.BSON;

{ TdjEngineStreamBSON }

class function TdjEngineStreamBSON.Deserialize(const AByteStream: TStream;
  const AValueType: TRttiType; const APropField: TRttiNamedObject;
  const AMasterObj: TObject; const AParams: IdjParams): TValue;
var
  LBSONReader: TBSONReader;
begin
  AByteStream.Position := 0;
  LBSONReader := TBSONReader.Create(AByteStream);
  try
    if LBSONReader.Read then
      Result := DeserializePropField(LBSONReader, AValueType, APropField, AMasterObj, AParams);
  finally
    LBSONReader.Free;
  end;
end;

class function TdjEngineStreamBSON.Serialize(const AValue: TValue;
  const APropField: TRttiNamedObject; const AParams: IdjParams;
  const AEnableCustomSerializers: Boolean): TBytesStream;
var
  LBSONWriter: TBsonWriter;
begin
  Result := TBytesStream.Create;
  LBSONWriter := TBsonWriter.Create(Result);
  try
    SerializePropField(LBSONWriter, AValue, APropField, AParams, AEnableCustomSerializers);
    Result.Position := 0;
  finally
    LBSONWriter.Free;
  end;
end;

end.
