unit FormMain;

interface

uses
  Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls, Model,
  System.Generics.Collections, DJSON.Params;

const

  MODE_JAVASCRIPT = 0;
  MODE_DATACONTRACT = 1;

  TYPE_PROPERTIES = 0;
  TYPE_FIELDS = 1;

type
  TMainForm = class(TForm)
    Image1: TImage;
    PanelTools: TPanel;
    Shape1: TShape;
    Shape2: TShape;
    Label1: TLabel;
    Label2: TLabel;
    RadioGroupSerializationMode: TRadioGroup;
    RadioGroupSerializationType: TRadioGroup;
    CheckBoxTypeAnnotations: TCheckBox;
    CheckBoxCustomSerializers: TCheckBox;
    ButtonSerializeSignleObject: TButton;
    ButtonDeserializeSignleObject: TButton;
    ButtonSerializeObjectList: TButton;
    ButtonDeserializeObjectList: TButton;
    Memo1: TMemo;
    Image2: TImage;
    Image3: TImage;
    Shape3: TShape;
    Label3: TLabel;
    ButtonOtherSerialize1: TButton;
    ButtonOtherDeserialize1: TButton;
    Label6: TLabel;
    procedure ButtonSerializeSignleObjectClick(Sender: TObject);
    procedure ButtonDeserializeSignleObjectClick(Sender: TObject);
    procedure ButtonSerializeObjectListClick(Sender: TObject);
    procedure ButtonDeserializeObjectListClick(Sender: TObject);
    procedure ButtonOtherSerialize1Click(Sender: TObject);
    procedure ButtonOtherDeserialize1Click(Sender: TObject);
  private
    { Private declarations }
    function BuildMapperParams: IdjParams;
    function BuildSampleObject: TPizza;
    function BuildSampleList: TObjectList<TPizza>;
    procedure ShowSingleObjectData(APizza: TPizza);
    procedure ShowListData(APizzaList: TObjectList<TPizza>);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses
  System.JSON, DJSON, System.Rtti, Winapi.Windows, Serializers, DJSON.Utils.RTTI;

{$R *.dfm}

function TMainForm.BuildMapperParams: IdjParams;
begin
  Result := dj.Default;
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
  // Register the custom serializer sor string type
  Result.Serializers.Register<String, TStringCustomSerializer>;
end;

function TMainForm.BuildSampleList: TObjectList<TPizza>;
var
  LNewPizza: TPizza;
begin
  Result := TObjectList<TPizza>.Create;

  LNewPizza := TPizza.Create;
  LNewPizza.ID := 1;
  LNewPizza.Name := 'Capricciosa pizza';
  LNewPizza.AnyTypeValue := 'This can be any type';
  LNewPizza.Image.LoadFromFile('..\..\PizzaCapricciosa.bmp');
  Result.Add(LNewPizza);

  LNewPizza := TPizza.Create;
  LNewPizza.ID := 2;
  LNewPizza.Name := 'Margherita pizza';
  LNewPizza.AnyTypeValue := 1254.5;
  LNewPizza.Image.LoadFromFile('..\..\PizzaMargherita.bmp');
  Result.Add(LNewPizza);

  LNewPizza := TPizza.Create;
  LNewPizza.ID := 3;
  LNewPizza.Name := 'Pepperoni pizza';
  LNewPizza.AnyTypeValue := TValue.From<TDateTime>(Now);
  LNewPizza.Image.LoadFromFile('..\..\PizzaSalamePiccante.bmp');
  Result.Add(LNewPizza);

  // Clear TImages
  Image1.Picture.Graphic := nil;
  Image2.Picture.Graphic := nil;
  Image3.Picture.Graphic := nil;
end;

function TMainForm.BuildSampleObject: TPizza;
begin
  Result := TPizza.Create;
  Result.ID := 1;
  Result.Name := 'Capricciosa pizza';
  Result.AnyTypeValue := 'This can be any type';
  Result.Image.LoadFromFile('..\..\PizzaCapricciosa.bmp');

  // Clear TImages
  Image1.Picture.Graphic := nil;
  Image2.Picture.Graphic := nil;
  Image3.Picture.Graphic := nil;
end;

procedure TMainForm.ButtonDeserializeObjectListClick(Sender: TObject);
var
  LPizzaList: TObjectList<TPizza>;
  LPerson: TPizza;
  LParams: IdjParams;
begin
  LParams := BuildMapperParams;
  // ---------------------
  if LParams.TypeAnnotations then
    LPizzaList := dj.FromJSON(Memo1.Lines.Text, LParams).&To<TObjectList<TPizza>>
  else
    LPizzaList := dj.FromJSON(Memo1.Lines.Text, LParams).ItemsOfType<TPizza>.&To<TObjectList<TPizza>>;
  // ---------------------
  try
    LPizzaList.OwnsObjects := True;
    ShowListData(LPizzaList);
  finally
    LPizzaList.Free;
  end;
end;

procedure TMainForm.ButtonDeserializeSignleObjectClick(Sender: TObject);
var
  LPizza: TPizza;
  LParams: IdjParams;
begin
  LParams := BuildMapperParams;
  // ---------------------
  LPizza := dj.FromJSON(Memo1.Lines.Text).Params(LParams).&To<TPizza>;
  // ---------------------
  try
    ShowSingleObjectData(LPizza);
  finally
    LPizza.Free;
  end;
end;

procedure TMainForm.ButtonOtherDeserialize1Click(Sender: TObject);
var
  LPizza: TPizza;
begin
  // ---------------------
  // Esempio di come deserializzare senza l'utilizzo di un oggetto "IomParams" ma specificando alcuni
  //  parametri direttamente sulla chiamata. In questo caso viene indicato di utilizzare il custom serializer
  //  "TStringCustomSerializer" per il tipo "String", inoltre viene indicato al mapper che la proprietà
  //  di tipo TValue contiene un tipo "String" altrimenti avendo optato per una serializzazione senza
  //  annotazione dei tipi non saprebbe che tipo deserializzare.
  LPizza := dj.FromJSON(Memo1.Lines.Text).CustomSerializer<String,TStringCustomSerializer>.ItemsOfType<String>.&To<TPizza>;
  // ---------------------
  try
    ShowSingleObjectData(LPizza);
  finally
    LPizza.Free;
  end;
end;

procedure TMainForm.ButtonOtherSerialize1Click(Sender: TObject);
var
  LPizza: TPizza;
  FJSONText: String;
begin
  // Init
  LPizza := BuildSampleObject;
  try
    // ---------------------
    // Esempio di come serializzare senza l'utilizzo di un oggetto "IomParams" ma specificando alcuni
    //  parametri direttamente sulla chiamata. In questo caso viene indicato di utilizzare il custom serializer
    //  "TStringCustomSerializer" per il tipo "String".
    FJSONText := dj.From(LPizza).CustomSerializer<String,TStringCustomSerializer>.ToJSON;
    // ---------------------
//    FJSONText := StringReplace(FJSONText,#$A,'',[rfReplaceAll]);
//    FJSONText := StringReplace(FJSONText,#$D,'',[rfReplaceAll]);
    Memo1.Clear;
    Memo1.Lines.Text := FJSONText;
  finally
    LPizza.Free;
  end;
end;

procedure TMainForm.ButtonSerializeObjectListClick(Sender: TObject);
var
  LPizzaList: TObjectList<TPizza>;
  LParams: IdjParams;
  FJSONText: String;
begin
  LParams     := BuildMapperParams;
  LPizzaList  := BuildSampleList;
  try
    // ---------------------
    FJSONText := dj.From(LPizzaList, LParams).ToJSON;
    // ---------------------
//    FJSONText := StringReplace(FJSONText,#$A,'',[rfReplaceAll]);
//    FJSONText := StringReplace(FJSONText,#$D,'',[rfReplaceAll]);
    Memo1.Clear;
    Memo1.Lines.Text := FJSONText;
  finally
    LPizzaList.Free;
  end;
end;

procedure TMainForm.ButtonSerializeSignleObjectClick(Sender: TObject);
var
  LPizza: TPizza;
  LParams: IdjParams;
  FJSONText: String;
begin
  LParams := BuildMapperParams;
  LPizza := BuildSampleObject;
  try
    // ---------------------
    FJSONText := dj.From(LPizza, LParams).ToJSON;
    // ---------------------
//    FJSONText := StringReplace(FJSONText,#$A,'',[rfReplaceAll]);
//    FJSONText := StringReplace(FJSONText,#$D,'',[rfReplaceAll]);
    Memo1.Clear;
    Memo1.Lines.Text := FJSONText;
  finally
    LPizza.Free;
  end;
end;

procedure TMainForm.ShowListData(APizzaList: TObjectList<TPizza>);
var
  LPizza: TPizza;
begin
  Memo1.Clear;
  Memo1.Lines.Add('');
  Memo1.Lines.Add('---------- Start deserialized --------------');
  for LPizza in APizzaList do
  begin
    Memo1.Lines.Add('');
    Memo1.Lines.Add('Class: ' + LPizza.ClassName);
    Memo1.Lines.Add('ID = ' +  LPizza.ID.ToString);
    Memo1.Lines.Add('Name = ' +  LPizza.Name);
    Memo1.Lines.Add('AnyTypeValue = ' +  LPizza.AnyTypeValue.ToString + '   (' + TdjRTTI.TypeInfoToQualifiedTypeName(LPizza.AnyTypeValue.TypeInfo) + ')');
  end;
  Memo1.Lines.Add('');
  Memo1.Lines.Add('---------- End deserialized --------------');
  // Images
  Image1.Picture.Bitmap := APizzaList[0].Image;
  Image2.Picture.Bitmap := APizzaList[1].Image;
  Image3.Picture.Bitmap := APizzaList[2].Image;
end;

procedure TMainForm.ShowSingleObjectData(APizza: TPizza);
begin
  Memo1.Clear;
  Memo1.Lines.Add('');
  Memo1.Lines.Add('---------- Start deserialized --------------');
  Memo1.Lines.Add('');
  Memo1.Lines.Add('Class: ' + APizza.ClassName);
  Memo1.Lines.Add('ID = ' +  APizza.ID.ToString);
  Memo1.Lines.Add('Name = ' +  APizza.Name);
  Memo1.Lines.Add('AnyTypeValue = ' +  APizza.AnyTypeValue.ToString + '   (' + TdjRTTI.TypeInfoToQualifiedTypeName(APizza.AnyTypeValue.TypeInfo) + ')');
  Memo1.Lines.Add('');
  Memo1.Lines.Add('---------- End deserialized --------------');
  // Images
  Image1.Picture.Bitmap := APizza.Image;
end;

end.
