unit FormMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Model, System.Generics.Collections,
  DJSON.Params;

const
  ENGINE_DOM = 0;
  ENGINE_STREAM = 1;
  ENGINE_JDO = 2;

  MODE_JAVASCRIPT = 0;
  MODE_DATACONTRACT = 1;

  TYPE_PROPERTIES = 0;
  TYPE_FIELDS = 1;

type
  TMainForm = class(TForm)
    PanelTools: TPanel;
    Shape1: TShape;
    Shape2: TShape;
    Shape3: TShape;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Shape4: TShape;
    Label4: TLabel;
    Shape5: TShape;
    Label5: TLabel;
    Label6: TLabel;
    RadioGroupSerializationMode: TRadioGroup;
    RadioGroupSerializationType: TRadioGroup;
    CheckBoxTypeAnnotations: TCheckBox;
    CheckBoxCustomSerializers: TCheckBox;
    ButtonSerializeSignleObject: TButton;
    ButtonDeserializeSignleObject: TButton;
    ButtonSerializeObjectList: TButton;
    ButtonDeserializeObjectList: TButton;
    ButtonOtherSerialize1: TButton;
    ButtonOtherDeserialize1: TButton;
    ButtonOtherSerialize2: TButton;
    ButtonOtherDeserialize2: TButton;
    ButtonOtherSerialize3: TButton;
    ButtonOtherDeserialize3: TButton;
    Memo1: TMemo;
    RadioGroupEngine: TRadioGroup;
    Shape6: TShape;
    Shape7: TShape;
    Label7: TLabel;
    Label8: TLabel;
    ButtonSerializeBSONSingleObject: TButton;
    ButtonDeserializeBSONSignleObject: TButton;
    ButtonSerializeBSONObjectList: TButton;
    ButtonDeserializeBSONObjectList: TButton;
    procedure ButtonSerializeSignleObjectClick(Sender: TObject);
    procedure ButtonDeserializeSignleObjectClick(Sender: TObject);
    procedure ButtonSerializeObjectListClick(Sender: TObject);
    procedure ButtonDeserializeObjectListClick(Sender: TObject);
    procedure ButtonOtherSerialize1Click(Sender: TObject);
    procedure ButtonOtherDeserialize1Click(Sender: TObject);
    procedure ButtonOtherSerialize2Click(Sender: TObject);
    procedure ButtonOtherDeserialize2Click(Sender: TObject);
    procedure ButtonOtherSerialize3Click(Sender: TObject);
    procedure ButtonOtherDeserialize3Click(Sender: TObject);
    procedure ButtonSerializeBSONSingleObjectClick(Sender: TObject);
    procedure ButtonDeserializeBSONSignleObjectClick(Sender: TObject);
    procedure ButtonSerializeBSONObjectListClick(Sender: TObject);
    procedure ButtonDeserializeBSONObjectListClick(Sender: TObject);
  private
    { Private declarations }
    FBytes: TBytes;
    function BuildMapperParams: IdjParams;
    function BuildSampleObject: TPerson;
    function BuildSampleList: TObjectList<TPerson>;
    procedure ShowSingleObjectData(APerson: TPerson);
    procedure ShowListData(APersonList: TObjectList<TPerson>);
  end;

var
  MainForm: TMainForm;

implementation

uses
  DJSON, System.JSON, System.Rtti, IdGlobal, DJSON.Utils;

{$R *.dfm}

function TMainForm.BuildMapperParams: IdjParams;
begin
  Result := dj.Default;
  // Serialization Engine
  case RadioGroupEngine.ItemIndex of
    ENGINE_DOM:    Result.Engine := eDelphiDOM;
    ENGINE_STREAM: Result.Engine := eDelphiStream;
    ENGINE_JDO:    Result.Engine := eJDO;
  end;
  // Serialization Mode
  case RadioGroupSerializationMode.ItemIndex of
    MODE_JAVASCRIPT:   Result.SerializationMode := smJavaScript;
    MODE_DATACONTRACT: Result.SerializationMode := smDataContract;
  end;
  // Serialization Type
  case RadioGroupSerializationType.ItemIndex of
    TYPE_PROPERTIES:   Result.SerializationType := stProperties;
    TYPE_FIELDS:       Result.SerializationType := stFields;
  end;
  // Type annotations
  Result.TypeAnnotations := CheckBoxTypeAnnotations.Checked;
  // Custom serializers
  Result.EnableCustomSerializers := CheckBoxCustomSerializers.Checked;
end;

function TMainForm.BuildSampleList: TObjectList<TPerson>;
var
  NewPerson: TPerson;
begin
  Result := TObjectList<TPerson>.Create;

  NewPerson := TPerson.Create(1, 'Maurizio Del Magno');
  NewPerson.NumTel.Add(   TNumTel.Create(1, '0541/605905', 1)   );
  NewPerson.NumTel.Add(   TNumTel.Create(2, '329/0583381', 1)   );
  NewPerson.NumTel.Add(   TNumTel.Create(3, '0541/694750', 1)   );
  Result.Add(NewPerson);

  NewPerson := TPerson.Create(2, 'Daniele Teti');
  NewPerson.NumTel.Add(   TNumTel.Create(4, '06/1122334',  2)   );
  NewPerson.NumTel.Add(   TNumTel.Create(5, '333/23456346',2)   );
  Result.Add(NewPerson);

  NewPerson := TPerson.Create(3, 'Omar Bossoni');
  NewPerson.NumTel.Add(   TNumTel.Create(6, '02/673927',   3)   );
  NewPerson.NumTel.Add(   TNumTel.Create(7, '347/3459276', 3)   );
  NewPerson.NumTel.Add(   TNumTel.Create(8, '332/6714399', 3)   );
  Result.Add(NewPerson);
end;

function TMainForm.BuildSampleObject: TPerson;
begin
  Result := TPerson.Create(1, 'Maurizio Del Magno');
  Result.NumTel.Add(   TNumTel.Create(1, '0541/605905', 1)   );
  Result.NumTel.Add(   TNumTel.Create(2, '329/0583381', 1)   );
  Result.NumTel.Add(   TNumTel.Create(3, '0541/694750', 1)   );
end;

procedure TMainForm.ButtonDeserializeBSONObjectListClick(Sender: TObject);
var
  LPersonList: TObjectList<TPerson>;
  LParams: IdjParams;
begin
  LParams := BuildMapperParams;
  // ---------------------
  if LParams.TypeAnnotations then
    LPersonList := dj.FromBson(FBytes, LParams).&To<TObjectList<TPerson>>
  else
    LPersonList := dj.FromBson(FBytes, LParams).ItemsOfType<TPerson>.&To<TObjectList<TPerson>>;
  // ---------------------
  try
    ShowListData(LPersonList);
  finally
    LPersonList.OwnsObjects := True;
    LPersonList.Free;
  end;
end;

procedure TMainForm.ButtonDeserializeBSONSignleObjectClick(Sender: TObject);
var
  LPerson: TPerson;
  LParams: IdjParams;
begin
  LParams := BuildMapperParams;
  LPerson := dj.FromBson(FBytes).Params(LParams).&To<TPerson>;
  try
    ShowSingleObjectData(LPerson);
  finally
    LPerson.Free;
  end;
end;

procedure TMainForm.ButtonDeserializeObjectListClick(Sender: TObject);
var
  LPersonList: TObjectList<TPerson>;
  LPerson: TPerson;
  LNumtel: TNumTel;
  LParams: IdjParams;
begin
  LParams := BuildMapperParams;
  LPersonList := dj.FromJSON(Memo1.Lines.Text, LParams).&To<TObjectList<TPerson>>;
  try
    LPersonList.OwnsObjects := True;
    ShowListData(LPersonList);
  finally
    LPersonList.Free;
  end;
end;

procedure TMainForm.ButtonDeserializeSignleObjectClick(Sender: TObject);
var
  LPerson: TPerson;
  LParams: IdjParams;
begin
  LParams := BuildMapperParams;
  // ---------------------
  LPerson := dj.FromJSON(Memo1.Lines.Text).Params(LParams).&To<TPerson>;
  // Oppure: LPerson := om.FromJSON(Memo1.Lines.Text, LParams).&To<TPerson>;
  // Oppure: LPerson := om.FromJSON(Memo1.Lines.Text).&To<TPerson>;
  // ---------------------
  try
    ShowSingleObjectData(LPerson);
  finally
    LPerson.Free;
  end;
end;

procedure TMainForm.ButtonOtherDeserialize1Click(Sender: TObject);
var
  LPerson: TPerson;
begin
  LPerson := TPerson.Create;
  try
    // ---------------------
    // Questo è il modo più semplice di utilizzare il mapper.
    // Da usare se il comportamento di default del mapper è consono alle esigenze
    dj.FromJSON(Memo1.Lines.Text).&To(LPerson);
    // ---------------------
    ShowSingleObjectData(LPerson);
  finally
    LPerson.Free;
  end;
end;

procedure TMainForm.ButtonOtherDeserialize2Click(Sender: TObject);
var
  LPersonList: TObjectList<TPerson>;
  LPerson: TPerson;
begin
  LPersonList := TObjectList<TPerson>.Create(True);
  // ---------------------
  // Utilizzo del mapper senza un oggetto "Params" ma specificando gli eventuali parametri
  //  desiderati direttamente sulla chiamata.
  //  IN questo caso si chiede la serializzazione per Fields (normalmente avviene per proprietà),
  //  annotazione dei tipi nel JSON attivata e disabilita gli eventuali custom serializers.
  dj.FromJSON(Memo1.Lines.Text).byFields.TypeAnnotationsON.CustomSerializersOFF.&To(LPersonList);
  // ---------------------
  try
    ShowListData(LPersonList);
  finally
    LPersonList.Free;
  end;
end;

procedure TMainForm.ButtonOtherDeserialize3Click(Sender: TObject);
var
  LObj: TObject;
begin
  // ---------------------
  // Utilizzo del mapper senza un oggetto "Params" ma specificando gli eventuali parametri
  //  desiderati direttamente sulla chiamata.
  //  IN questo caso si chiede la serializzazione per Fields (normalmente avviene per proprietà),
  //  annotazione dei tipi nel JSON attivata e disabilita gli eventuali custom serializers.
  //  NB: In questo caso non viene specificato il tipo del risultato nella chiamata, tale
  //       informazione viene presa direttamente dal JSON (TypeAnnotationsON), in questo
  //       caso il risultato ottenuto è un TObject.
  LObj := dj.FromJSON(Memo1.Lines.Text).byFields.TypeAnnotationsON.CustomSerializersOFF.ToObject;
  // ---------------------
  try
    ShowSingleObjectData(LObj as TPerson);
  finally
    LObj.Free;
  end;
end;

procedure TMainForm.ButtonOtherSerialize1Click(Sender: TObject);
var
  LPerson: TPerson;
begin
  LPerson := BuildSampleObject;
  try
    Memo1.Clear;
    Memo1.Lines.Text := dj.From(LPerson).ToJSON;
  finally
    LPerson.Free;
  end;
end;

procedure TMainForm.ButtonOtherSerialize2Click(Sender: TObject);
var
  LPersonList: TObjectList<TPerson>;
begin
  LPersonList := BuildSampleList;
  try
    // ---------------------
    // Utilizzo del mapper senza un oggetto "Params" ma specificando gli eventuali parametri
    //  desiderati direttamente sulla chiamata.
    //  IN questo caso si chiede la serializzazione per Fields (normalmente avviene per proprietà),
    //  annotazione dei tipi nel JSON attivata e disabilita gli eventuali custom serializers.
    Memo1.Clear;
    Memo1.Lines.Text := dj.From(LPersonList).byFields.TypeAnnotationsON.CustomSerializersOFF.ToJSON;
  finally
    LPersonList.Free;
  end;
end;

procedure TMainForm.ButtonOtherSerialize3Click(Sender: TObject);
var
  LPerson: TPerson;
begin
  LPerson := BuildSampleObject;
  try
    // Utilizzo del mapper senza un oggetto "Params" ma specificando gli eventuali parametri
    //  desiderati direttamente sulla chiamata.
    //  IN questo caso si chiede la serializzazione per Fields (normalmente avviene per proprietà),
    //  annotazione dei tipi nel JSON attivata e disabilita gli eventuali custom serializers.
    Memo1.Clear;
    Memo1.Lines.Text := dj.From(LPerson).byFields.TypeAnnotationsON.CustomSerializersOFF.ToJSON;
  finally
    LPerson.Free;
  end;
end;

procedure TMainForm.ButtonSerializeBSONObjectListClick(Sender: TObject);
var
  LPersonList: TObjectList<TPerson>;
  LParams: IdjParams;
begin
  LParams     := BuildMapperParams;
  LPersonList := BuildSampleList;
  try
    SetLength(FBytes, 0);
    FBytes := dj.From(LPersonList, LParams).ToBsonAsBytes;
    Memo1.Clear;
    Memo1.Lines.Text := TdjUtils.Bytes2String(FBytes);
  finally
    LPersonList.Free;
  end;
end;

procedure TMainForm.ButtonSerializeBSONSingleObjectClick(Sender: TObject);
var
  LPerson: TPerson;
  LParams: IdjParams;
begin
  LParams := BuildMapperParams;
  LPerson := BuildSampleObject;
  try
    FBytes := dj.From(LPerson, LParams).ToBsonAsBytes;
    Memo1.Clear;
    Memo1.Lines.Text := TdjUtils.Bytes2String(FBytes);
  finally
    LPerson.Free;
  end;
end;

procedure TMainForm.ButtonSerializeObjectListClick(Sender: TObject);
var
  LPersonList: TObjectList<TPerson>;
  LParams: IdjParams;
begin
  LParams     := BuildMapperParams;
  LPersonList := BuildSampleList;
  try
    Memo1.Clear;
    Memo1.Lines.Text := dj.From(LPersonList, LParams).ToJSON;
  finally
    LPersonList.Free;
  end;
end;

procedure TMainForm.ButtonSerializeSignleObjectClick(Sender: TObject);
var
  LPerson: TPerson;
  LParams: IdjParams;
begin
  LParams := BuildMapperParams;
  LPerson := BuildSampleObject;
  try
    Memo1.Clear;
    Memo1.Lines.Text := dj.From(LPerson, LParams).ToJSON;
  finally
    LPerson.Free;
  end;
end;

procedure TMainForm.ShowListData(APersonList: TObjectList<TPerson>);
var
  LPerson: TPerson;
  LNumtel: TNumTel;
begin
  Memo1.Lines.BeginUpdate;
  try
    Memo1.Lines.Add('');
    Memo1.Lines.Add('');
    Memo1.Lines.Add('');
    Memo1.Lines.Add('---------- Start deserialized --------------');
    for LPerson in APersonList do
    begin
      Memo1.Lines.Add('');
      Memo1.Lines.Add('Class: ' + TPerson.ClassName);
      Memo1.Lines.Add('ID = ' +  LPerson.ID.ToString);
      Memo1.Lines.Add('Descrizione = ' +  LPerson.Descrizione);
      for LNumtel in LPerson.NumTel do
      begin
        Memo1.Lines.Add('');
        Memo1.Lines.Add('     Class: ' + LNumtel.ClassName);
        Memo1.Lines.Add('     ID: ' + LNumtel.ID.ToString);
        Memo1.Lines.Add('     MasterID: ' + LNumtel.MasterID.ToString);
        Memo1.Lines.Add('     Numero: ' + LNumtel.Numero);
      end;
    end;
    Memo1.Lines.Add('---------- End deserialized --------------');
  finally
    Memo1.Lines.EndUpdate;
  end;
end;

procedure TMainForm.ShowSingleObjectData(APerson: TPerson);
var
  LNumTel: TNumTel;
begin
  Memo1.Lines.BeginUpdate;
  try
    Memo1.Lines.Add('');
    Memo1.Lines.Add('');
    Memo1.Lines.Add('');
    Memo1.Lines.Add('---------- Start deserialized --------------');
    Memo1.Lines.Add('Class: ' + TPerson.ClassName);
    Memo1.Lines.Add('ID = ' +  APerson.ID.ToString);
    Memo1.Lines.Add('Descrizione = ' +  APerson.Descrizione);
    for LNumtel in APerson.NumTel do
    begin
      Memo1.Lines.Add('');
      Memo1.Lines.Add('     Class: ' + LNumtel.ClassName);
      Memo1.Lines.Add('     ID: ' + LNumtel.ID.ToString);
      Memo1.Lines.Add('     MasterID: ' + LNumtel.MasterID.ToString);
      Memo1.Lines.Add('     Numero: ' + LNumtel.Numero);
    end;
    Memo1.Lines.Add('---------- End deserialized --------------');
  finally
    Memo1.Lines.EndUpdate;
  end;
end;

end.
