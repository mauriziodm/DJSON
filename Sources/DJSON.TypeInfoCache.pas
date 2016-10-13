unit DJSON.TypeInfoCache;

interface

uses
  DJSON.Duck.Interfaces, System.Generics.Collections;

type

  TdjDuckType = (dtNone=0, dtList, dtStreamable, dtDictionary, dtStream);

  TdjTypeInfoCacheItem = class
  public
    DuckType: TdjDuckType;
    DuckListWrapper: IdjDuckList;
    DuckStreamableWrapper: IdjDuckStreamable;
    DuckDictionaryWrapper: IdjDuckDictionary;
  end;

  TdjTypeInfoCacheInternalContainer = TObjectDictionary<String, TdjTypeInfoCacheItem>;
  TdjTypeInfoCache = class
  private
    FInternatContainer: TdjTypeInfoCacheInternalContainer;
  public
    constructor Create;
    destructor Destroy; override;
    function Get(const AObj:TObject): TdjTypeInfoCacheItem;
  end;

implementation

uses
  DJSON.Factory, System.Classes;

{ TdjTypeInfoCache }

constructor TdjTypeInfoCache.Create;
begin
  inherited;
  FInternatContainer := TdjTypeInfoCacheInternalContainer.Create([doOwnsValues]);
end;

destructor TdjTypeInfoCache.Destroy;
begin
  FInternatContainer.Free;
  inherited;
end;

function TdjTypeInfoCache.Get(const AObj: TObject): TdjTypeInfoCacheItem;
begin
  if FInternatContainer.TryGetValue(AObj.ClassName, Result) then
  begin
    case Result.DuckType of
      dtNone:;
      dtList: Result.DuckListWrapper.SetObject(AObj);
      dtStreamable: Result.DuckStreamableWrapper.SetObject(AObj);
      dtDictionary: Result.DuckDictionaryWrapper.SetObject(AObj);
      dtStream:;
    end;
  end
  else
  begin
    Result := TdjTypeInfoCacheItem.Create;
    if AObj is TStream then
      Result.DuckType := TdjDuckType.dtStream
    else
    if TdjFactory.TryWrapAsDuckDictionary(AObj, Result.DuckDictionaryWrapper) then
      Result.DuckType := TdjDuckType.dtDictionary
    else
    if TdjFactory.TryWrapAsDuckList(AObj, Result.DuckListWrapper) then
      Result.DuckType := TdjDuckType.dtList
    else
    if TdjFactory.TryWrapAsDuckStreamable(AObj, Result.DuckStreamableWrapper) then
      Result.DuckType := TdjDuckType.dtStreamable
    else
      Result.DuckType := TdjDuckType.dtNone;
    FInternatContainer.Add(AObj.ClassName, Result);
  end;
end;

end.
