unit Serializers;

interface

uses DJSON.Serializers, System.Rtti, System.JSON;

type

  TNumTelCustomSerializer = class(TdjDOMCustomSerializer)
  public
    class function Serialize(const AValue:TValue): TJSONValue; override;
    class function Deserialize(const AJSONValue:TJSONValue; const AExistingValue:TValue): TValue; override;
    class function isTypeNotificationCompatible: Boolean; override;
  end;

implementation

uses
  Model, System.SysUtils, System.Classes;

{ TPhoneNumberCustomSerializer }

class function TNumTelCustomSerializer.Deserialize(const AJSONValue: TJSONValue;
  const AExistingValue: TValue): TValue;
var
  LStringList: TStrings;
  LNumTel: TNumTel;
begin
  LStringList := TStringList.Create;
  try
    LStringList.CommaText := AJSONValue.Value;
    LNumTel := TNumTel.Create(LStringList[0].ToInteger, LStringList[2], LStringList[1].ToInteger);
    Result := TValue.From<TNumTel>(LNumTel);
  finally
    LStringList.Free;
  end;
end;

class function TNumTelCustomSerializer.isTypeNotificationCompatible: Boolean;
begin
  Result := True;
end;

class function TNumTelCustomSerializer.Serialize(const AValue: TValue): TJSONValue;
var
  LStringList: TStrings;
  LNumTel: TNumTel;
begin
  LNumTel := AValue.AsType<TNumTel>;
  LStringList := TStringList.Create;
  try
    LStringList.Add(LNumTel.ID.ToString);
    LStringList.Add(LNumTel.MasterID.ToString);
    LStringList.Add(LNumTel.Numero);
    Result := TJSONString.Create(LStringList.CommaText);
  finally
    LStringList.Free;
  end;
end;

end.
