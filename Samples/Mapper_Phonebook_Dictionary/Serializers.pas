unit Serializers;

interface

uses DJSON.Serializers, System.Rtti, System.JSON;

type

  TPhoneNumberCustomSerializer = class(TdjDOMCustomSerializer)
  public
    class function Serialize(const AValue:TValue): TJSONValue; override;
    class function Deserialize(const AJSONValue:TJSONValue; const AExistingValue:TValue): TValue; override;
    class function isTypeNotificationCompatible: Boolean; override;
  end;

implementation

uses
  Model, System.SysUtils, System.Classes, Interfaces;

{ TPhoneNumberCustomSerializer }

class function TPhoneNumberCustomSerializer.Deserialize(const AJSONValue: TJSONValue;
  const AExistingValue: TValue): TValue;
var
  LStringList: TStrings;
  LPhoneNumber: IPhoneNumber;
begin
  LStringList := TStringList.Create;
  try
    LStringList.CommaText := AJSONValue.Value;
    LPhoneNumber := TPhoneNumber.Create(LStringList[0].ToInteger, LStringList[2], LStringList[1].ToInteger);
    Result := TValue.From<IPhoneNumber>(LPhoneNumber);
  finally
    LStringList.Free;
  end;
end;

class function TPhoneNumberCustomSerializer.isTypeNotificationCompatible: Boolean;
begin
  Result := True;
end;

class function TPhoneNumberCustomSerializer.Serialize(const AValue: TValue): TJSONValue;
var
  LStringList: TStrings;
  LPhoneNumber: IPhoneNumber;
begin
  LPhoneNumber := AValue.AsType<IPhoneNumber>;
  LStringList := TStringList.Create;
  try
    LStringList.Add(LPhoneNumber.ID.ToString);
    LStringList.Add(LPhoneNumber.MasterID.ToString);
    LStringList.Add(LPhoneNumber.Number);
    Result := TJSONString.Create(LStringList.CommaText);
  finally
    LStringList.Free;
  end;
end;

end.
