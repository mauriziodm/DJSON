unit DJSON.Engine.Interfaces;

interface

uses
  System.Rtti, DJSON.Params;

type

  TdjEngineIntf = class abstract
  public
    class function Serialize(const AValue: TValue; const APropField: TRttiNamedObject; const AParams: IdjParams; const AEnableCustomSerializers:Boolean=True): String; virtual; abstract;
    class function Deserialize(const AJSONText:String; const AValueType: TRttiType; const APropField: TRttiNamedObject; const AMasterObj: TObject; const AParams: IdjParams): TValue; virtual; abstract;
  end;

implementation

end.
