unit Model;

interface

uses
  System.Classes, System.SysUtils,
  System.Generics.Collections, DJSON.Attributes, System.JSON, Serializers;

type

  [djSerializerDOM(TNumTelCustomSerializerDOM)]  // Or register the custom serializer in a IomParams object or direct in the command
  [djSerializerJDO(TNumTelCustomSerializerJDO)]  // Or register the custom serializer in a IomParams object or direct in the command
  [djSerializerStream(TNumTelCustomSerializerStream)]  // Or register the custom serializer in a IomParams object or direct in the command
  TNumTel = class
  private
    FID: Integer;
    FMasterID: Integer;
    FNumero: String;
    function GetID: Integer;
    function GetMasterID: Integer;
    function GetNumero: String;
    procedure SetID(const Value: Integer);
    procedure SetMasterID(const Value: Integer);
    procedure SetNumero(const Value: String);
  public
    constructor Create(AID:Integer; ANumero:String; AMasterID:Integer); overload;
    property ID: Integer read GetID write SetID;
    property Numero:String read GetNumero write SetNumero;
    property MasterID:Integer read GetMasterID write SetMasterID;
  end;

  TPerson = class
  private
    FID: Integer;
    FDescrizione: String;
    FNote: TStringList;
    FNumTel: TObjectList<TNumTel>;
    FSesso: Char;
    FEta: Byte;
    FViaggiEffettuati: Word;
    FLuogoDiNascita: String;
    function GetDescrizione: String;
    function GetID: Integer;
    function GetNumTel: TObjectList<TNumTel>;
    procedure SetDescrizione(const Value: String);
    procedure SetID(const Value: Integer);
  public
    constructor Create; overload;
    constructor Create(AID:Integer; ADescrizione:String); overload;
    destructor Destroy; override;
    property ID:Integer read GetID write SetID;
    property Descrizione:String read GetDescrizione write SetDescrizione;
    property Sesso:Char read FSesso write FSesso;
    property Eta:Byte read FEta write FEta;
    property LuogoDiNascita: String read FLuogoDiNascita write FLuogoDiNascita;
    property ViaggiEffettuati:Word read FViaggiEffettuati write FViaggiEffettuati;
    property NumTel:TObjectList<TNumTel> read GetNumTel;
    property Note: TStringList read FNote write FNote;
  end;

implementation


{ TMyClass }

constructor TPerson.Create(AID:Integer; ADescrizione:String);
begin
  Self.Create;
  FID := AID;
  FDescrizione := ADescrizione;
end;

constructor TPerson.Create;
begin
  inherited;
  FNumTel := TObjectList<TNumTel>.Create;
  FNote := TStringList.Create;
end;

destructor TPerson.Destroy;
begin
  FNote.Free;
  FNumTel.Free;
  inherited;
end;

function TPerson.GetDescrizione: String;
begin
  Result := FDescrizione;
end;

function TPerson.GetID: Integer;
begin
  Result := FID;
end;

function TPerson.GetNumTel: TObjectList<TNumTel>;
begin
  Result := FNumTel;
end;

procedure TPerson.SetDescrizione(const Value: String);
begin
  FDescrizione := Value;
end;

procedure TPerson.SetID(const Value: Integer);
begin
  FID := Value;
end;

{ TNumTel }

constructor TNumTel.Create(AID: Integer; ANumero: String; AMasterID: Integer);
begin
  inherited Create;
  FID := AID;
  FNumero := ANumero;
  FMasterID := AMasterID;
end;

function TNumTel.GetID: Integer;
begin
  Result := FID;
end;

function TNumTel.GetMasterID: Integer;
begin
  Result := FMasterID;
end;

function TNumTel.GetNumero: String;
begin
  Result := FNumero;
end;

procedure TNumTel.SetID(const Value: Integer);
begin
  FID := Value;
end;

procedure TNumTel.SetMasterID(const Value: Integer);
begin
  FMasterID := Value;
end;

procedure TNumTel.SetNumero(const Value: String);
begin
  FNumero := Value;
end;

end.
