unit DemoTests;

interface

uses
  DUnitX.TestFramework,
  System.Rtti,
  System.JSON,
  DJSON.Serializers,
  DJSON.Params;

type
  THtmlColorConverter = class(TdjDOMCustomSerializer)
    class function Serialize(const AValue: TValue): TJSONValue; override;
    class function Deserialize(const AJSONValue: TJSONValue; const AExistingValue: TValue): TValue; override;
    class function isTypeNotificationCompatible: Boolean; override;
  end;

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

  TPersonDemo = class
  private
    FName: string;
    FAge: Integer;
    FJob: string;
  published
    property Name: string read FName write FName;
    property Age: Integer read FAge write FAge;
    property Job: string read FJob write FJob;
  end;

  TSession = class
  private
    FName: string;
    FDate: TDateTime;
  published
    property Name: string read FName write FName;
    property Date: TDateTime read FDate write FDate;
  end;

  TCity = class
  private
    FName: string;
    FPopulation: Integer;
  published
    property Name: string read FName write FName;
    property Population: Integer read FPopulation write FPopulation;
  end;

  [TestFixture]
  TDemoTests = class(TObject)
  private
    FParams: IdjParams;
  public
    [Setup]
    procedure Setup;
    [TearDown]
    procedure TearDown;
    [Test]
    procedure JsonConverter;
    [Test]
    procedure SerializationGuide;
    [Test]
    procedure SerializationBasics;
    [Test]
    procedure SerializationBasics2;
  end;

implementation

uses
  System.SysUtils,
  DJSON,
  System.Generics.Collections;

procedure TDemoTests.SerializationBasics;
var
  LRoles: TList<string>;
begin
  LRoles := TList<string>.Create;
  try
    LRoles.AddRange(['User', 'Admin']);
    Assert.AreEqual('["User","Admin"]', dj.From(LRoles, FParams).ToJson);
  finally
    LRoles.Free;
  end;
end;

procedure TDemoTests.SerializationBasics2;
var
  s: TSession;
begin
  s := TSession.Create;
  try
    s.Name := 'Serialize All The Things';
    s.Date := StrToDate('03.07.2017');
    FParams.SerializationMode := smJavaScript;
    Assert.AreEqual('', dj.From(s, FParams).ToJson);
  finally
    s.Free;
  end;
end;

procedure TDemoTests.SerializationGuide;
var
  LResult: string;
  LRoles: TList<string>;
  LDailyRegistrations: TDictionary<TDateTime, Integer>;
  LCity: TCity;
begin
  LRoles := TList<string>.Create;
  try
    LRoles.AddRange(['User', 'Admin']);
    LResult := dj.From(LRoles, FParams).ToJson;
    Assert.AreEqual('["User","Admin"]', LResult);
  finally
    LRoles.Free;
  end;

  LDailyRegistrations := TDictionary<TDateTime, Integer>.Create;
  try
    LDailyRegistrations.Add(StrToDate('02.07.2017'), 23);
    LDailyRegistrations.Add(StrToDate('10.08.2017'), 50);
    LResult := dj.From(LDailyRegistrations, FParams).ToJson;
    Assert.AreEqual('[{"2017-07-02T00:00:00.000Z":23},{"2017-08-10T00:00:00.000Z":50}]', //
      LResult);
  finally
    LDailyRegistrations.Free;
  end;

  LCity := TCity.Create;
  try
    LCity.Name := 'Oslo';
    LCity.Population := 650000;
    LResult := dj.From(LCity, FParams).ToJson;
    Assert.AreEqual('{"Name":"Oslo","Population":650000}', LResult);
  finally
    LCity.Free;
  end;
end;

procedure TDemoTests.Setup;
begin
  FParams := dj.Default;
  FParams.Engine := eDelphiDOM;
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
    Assert.AreEqual('{"Red":255,"Green":0,"Blue":0}', LJson);
    FParams.EnableCustomSerializers := True;
    FParams.Serializers.Register<THtmlColor>(THtmlColorConverter);
    LJson := dj.From(LRed, FParams).ToJson;
    Assert.AreEqual('"#FF0000"', LJson);
  finally
    LRed.Free;
  end;
end;

{ THtmlColor }

constructor THtmlColor.Create(ARed, AGreen, ABlue: Integer);
begin
  FRed := ARed;
  FGreen := AGreen;
  FBlue := ABlue;
end;

{ THtmlColorConverter }

class function THtmlColorConverter.Deserialize(const AJSONValue: TJSONValue; const AExistingValue: TValue): TValue;
var
  hexString: string;
begin
  if not (AJSONValue is TJSONString) then
    raise Exception.Create('Wrong serialization.');
  // get hex string
  hexString := AJSONValue.Value;
  hexString := hexString.TrimLeft(['#']);
  Result := THtmlColor.Create(              // build html color from hex
    hexString.Substring(0, 2).ToInteger, //
    hexString.Substring(2, 2).ToInteger, //
    hexString.Substring(3, 2).ToInteger//
  );
end;

class function THtmlColorConverter.isTypeNotificationCompatible: Boolean;
begin
  inherited;
  Result := True;
end;

class function THtmlColorConverter.Serialize(const AValue: TValue): TJSONValue;
var
  LColor: THtmlColor;
  hexString: string;
begin
  inherited;
  LColor := AValue.AsType<THtmlColor>;
  hexString := Format('%x%.2x%.2x', [LColor.Red, LColor.Green, LColor.Blue]);
  Result := TJSONString.Create('#' + hexString);
end;

initialization
  TDUnitX.RegisterTestFixture(TDemoTests);

end.

