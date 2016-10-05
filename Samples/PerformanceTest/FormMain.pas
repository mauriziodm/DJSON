unit FormMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Edit,
  System.Generics.Collections, Model, JsonDataObjects;

type
  TMainForm = class(TForm)
    ButtonCreate: TButton;
    eNumOfObjects: TEdit;
    LabelElapsedCreate: TLabel;
    ButonSerializeDOM: TButton;
    LabelElapsedSerializeDOM: TLabel;
    ButtonDeserializeDOM: TButton;
    LabelElapsedDeserializeDOM: TLabel;
    ButtonDeserializaStream: TButton;
    LabelElapsedDeserializeStream: TLabel;
    ButtonDeserializaJDO: TButton;
    LabelElapsedDeserializeJDO: TLabel;
    Button1: TButton;
    procedure ButtonCreateClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure ButonSerializeDOMClick(Sender: TObject);
    procedure ButtonDeserializeDOMClick(Sender: TObject);
    procedure ButtonDeserializaStreamClick(Sender: TObject);
    procedure ButtonDeserializaJDOClick(Sender: TObject);
    function Prova: TJsonDataValue;
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    FList: TObjectList<TPerson>;
    FJSONText: String;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

uses
  System.Diagnostics, DJSON, System.JSON, DeserializeStreamU, DeserializeDOMU,
  DeserializeJDOU, DJSON.Engine.Stream, DJSON.Engine.DOM, DJSON.Utils.RTTI, DJSON.Params, ObjectsMappers,
  DJSON.Engine.JDO;

{$R *.fmx}

procedure TMainForm.ButonSerializeDOMClick(Sender: TObject);
var
  LStopWatch: TStopWatch;
begin
  if not Assigned(FList) then
    raise Exception.Create('Sample objects not created.');

  LStopWatch := TStopwatch.StartNew;

  FJSONText := dj.From(FList).ToJSON;
  FreeAndNil(FList);

  LStopWatch.Stop;
  LabelElapsedSerializeDOM.Text := LStopWatch.ElapsedMilliseconds.ToString + ' ms';

end;

procedure TMainForm.Button1Click(Sender: TObject);
var
  Tmp: TJsonDataValue;
begin
  Tmp := Prova;
  ShowMessage(IntToStr(Tmp.IntValue));
end;

procedure TMainForm.ButtonCreateClick(Sender: TObject);
var
  LCurrPersonID, LCurrNumberID, LNumOfObjectsToCreate: Integer;
  LNewPerson: TPerson;
  LStopWatch: TStopWatch;
begin
  if Assigned(FList) then
    FreeAndNil(FList);

  LStopWatch := TStopwatch.StartNew;

  LNumOfObjectsToCreate := StrToInt(eNumOfObjects.Text);
  FList := TObjectList<TPerson>.Create;
  LCurrNumberID := 0;
  for LCurrPersonID := 1 to LNumOfObjectsToCreate do
  begin
    LNewPerson := TPerson.Create(LCurrPersonID, 'Maurizio Del Magno');
    Inc(LCurrNumberID);
    LNewPerson.NumTel.Add(   TNumTel.Create(LCurrNumberID, '0541/605905', LCurrPersonID)   );
    Inc(LCurrNumberID);
    LNewPerson.NumTel.Add(   TNumTel.Create(LCurrNumberID, '329/0583381', LCurrPersonID)   );
    Inc(LCurrNumberID);
    LNewPerson.NumTel.Add(   TNumTel.Create(LCurrNumberID, '0541/694750', LCurrPersonID)   );
    FList.Add(LNewPerson);
  end;

  LStopWatch.Stop;
  LabelElapsedCreate.Text := LStopWatch.ElapsedMilliseconds.ToString + ' ms';
end;

procedure TMainForm.ButtonDeserializaJDOClick(Sender: TObject);
var
  ResultList: TObjectList<TPerson>;
  LStopWatch: TStopWatch;
  LParams: IdjParams;
begin
  try
    LStopWatch := TStopwatch.StartNew;

    ResultList := TObjectList<TPerson>.Create;
    LParams := dj.Default;
    LParams.ItemsValueDefaultTypeInfo := TypeInfo(TPerson);
    TdjEngineJDO.Deserialize(FJSONText, TdjRTTI.TypeInfoToRttiType(TypeInfo(TObjectList<TPerson>)), nil, ResultList, LParams);

    LStopWatch.Stop;
    LabelElapsedDeserializeJDO.Text := LStopWatch.ElapsedMilliseconds.ToString + ' ms   (' + IntToStr(ResultList.Count) + ' items)';
  finally
    ResultList.Free;
  end;
end;

procedure TMainForm.ButtonDeserializaStreamClick(Sender: TObject);
var
  ResultList: TObjectList<TPerson>;
  LStopWatch: TStopWatch;
  LParams: IdjParams;
begin
  try
    LStopWatch := TStopwatch.StartNew;

    ResultList := TObjectList<TPerson>.Create;
    LParams := dj.Default;
    LParams.ItemsValueDefaultTypeInfo := TypeInfo(TPerson);
    TdjEngineStream.Deserialize(FJSONText, TdjRTTI.TypeInfoToRttiType(TypeInfo(TObjectList<TPerson>)), nil, ResultList, LParams);

//    ResultList := dj.FromJSON(FJSONText).ItemsOfType<TPerson>.&To<TObjectList<TPerson>>;
//    ResultList := TDOMDeserializer.Deserialize(FJSONText);

    LStopWatch.Stop;
    LabelElapsedDeserializeStream.Text := LStopWatch.ElapsedMilliseconds.ToString + ' ms   (' + IntToStr(ResultList.Count) + ' items)';
  finally
    ResultList.Free;
  end;

//  try
//    LStopWatch := TStopwatch.StartNew;
//
//    ResultList := TStreamDeserializer.Deserialize(FJSONText);
//
//    LStopWatch.Stop;
//    LabelElapsedDeserializeStream.Text := LStopWatch.ElapsedMilliseconds.ToString + ' ms   (' + IntToStr(ResultList.Count) + ' items)';
//  finally
//    ResultList.Free;
//  end;
end;

procedure TMainForm.ButtonDeserializeDOMClick(Sender: TObject);
var
  ResultList: TObjectList<TPerson>;
  LStopWatch: TStopWatch;
  LParams: IdjParams;
begin
  try
    LStopWatch := TStopwatch.StartNew;

    ResultList := TObjectList<TPerson>.Create;
    LParams := dj.Default;
    LParams.ItemsValueDefaultTypeInfo := TypeInfo(TPerson);
    TdjEngineDOM.Deserialize(FJSONText, TdjRTTI.TypeInfoToRttiType(TypeInfo(TObjectList<TPerson>)), nil, ResultList, LParams);

//    ResultList := dj.FromJSON(FJSONText).ItemsOfType<TPerson>.&To<TObjectList<TPerson>>;
//    ResultList := TDOMDeserializer.Deserialize(FJSONText);

//    LJSONValue := TJSONObject.ParseJSONValue(FJSONText) as TJSONArray;
//    ResultList := Mapper.JSONArrayToObjectList<TPerson>(LJSONValue);

    LStopWatch.Stop;
    LabelElapsedDeserializeDOM.Text := LStopWatch.ElapsedMilliseconds.ToString + ' ms   (' + IntToStr(ResultList.Count) + ' items)';
  finally
//    LJSONValue.Free;
    ResultList.Free;
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  if Assigned(FList) then
    FList.Free;
end;

function TMainForm.Prova: TJsonDataValue;
begin
  Result.IntValue := 25;
end;

end.
