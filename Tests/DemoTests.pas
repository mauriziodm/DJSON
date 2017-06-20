unit DemoTests;

interface

uses
  DJSON.Serializers,
  DUnitX.TestFramework,
  System.Rtti,
  System.JSON,
  DJSON.Params;

type
  [TestFixture]
  TDemoTests = class(TObject)
  private
    FParams: IdjParams;
  public
    type
      THtmlColorConverter = class(TdjDOMCustomSerializer)
        class function Serialize(const AValue: TValue): TJSONValue; override;
        class function Deserialize(const AJSONValue: TJSONValue; const AExistingValue: TValue): TValue; override;
        class function isTypeNotificationCompatible: Boolean; override;
      end;

      [djSerializerDOM(THtmlColorConverter)]
      THtmlColor = class
      private
        FRed: Integer;
        FGreen: Integer;
        FBlue: Integer;
      public
        constructor Create(ARed, AGreen, ABlue: Integer);
      published
        property Red: Integer read FRed write FRed;
        property Green: Integer read FGreen write FGreen;
        property Blue: Integer read FBlue write FBlue;
      end;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    // Sample Methods
    // Simple single Test
    [Test]
    procedure JsonConverter;
    // Test with TestCase Attribute to supply parameters.
    [Test]
    [TestCase('TestA', '1,2')]
    [TestCase('TestB', '3,4')]
    procedure Test2(const AValue1: Integer; const AValue2: Integer);
  end;

implementation

uses
  System.SysUtils,
  DJSON;

procedure TDemoTests.Setup;
begin
  FParams := dj.Default;
end;

procedure TDemoTests.TearDown;
begin
end;

procedure TDemoTests.JsonConverter;
var
  LRed: THtmlColor;
  LJson: string;
begin
  LRed := THtmlColor.Create(255, 0, 0);
  try
    LJson := dj.From(LRed, FParams).ToJson;
    // {
    //   "Red": 255,
    //   "Green": 0,
    //   "Blue": 0
    // }
    FParams.EnableCustomSerializers := True;
    FParams.Serializers.Register<THtmlColor>(THtmlColorConverter);
    LJson := dj.From(LRed, FParams).ToJson;
  finally
    LRed.Free;
  end;

end;

procedure TDemoTests.Test2(const AValue1: Integer; const AValue2: Integer);
begin
end;

{ TDemoTests.THtmlColor }

constructor TDemoTests.THtmlColor.Create(ARed, AGreen, ABlue: Integer);
begin
  FRed := ARed;
  FGreen := AGreen;
  FBlue := ABlue;
end;

{ TDemoTests.THtmlColorConverter }

class function TDemoTests.THtmlColorConverter.Deserialize(const AJSONValue: TJSONValue; const AExistingValue: TValue): TValue;
begin

end;

class function TDemoTests.THtmlColorConverter.isTypeNotificationCompatible: Boolean;
begin
  inherited;
  Result := True;
end;

class function TDemoTests.THtmlColorConverter.Serialize(const AValue: TValue): TJSONValue;
var
  LColor: TDemoTests.THtmlColor;
  hexString: string;
begin
  inherited;
  LColor := AValue.AsType<THtmlColor>;
  hexString := Format('%x%x%x', [LColor.Red, LColor.Green, LColor.Blue]);
  Result := TJSONString.Create('#' + hexString);
end;

initialization
  TDUnitX.RegisterTestFixture(TDemoTests);

end.

