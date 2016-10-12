unit DJSON.TypeInfoCache;

interface

uses
  DJSON.Duck.Interfaces, System.Generics.Collections;

type

  TdjDuckType = (dtNone=0, dtList, dtStreamable, dtDictionary);

  TdjTypeInfoCacheItem = class
  public
    FDuckType: TdjDuckType;
    FDuckListWrapper: IdjDuckList;
    FDuckStreamableWrapper: IdjDuckStreamable;
    FDuckDictionaryWrapper: IdjDuckDictionary;
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
  DJSON.Factory;

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
    case Result.FDuckType of
      dtNone:;
      dtList: Result.FDuckListWrapper.SetObject(AObj);
      dtStreamable: Result.FDuckStreamableWrapper.SetObject(AObj);
      dtDictionary: Result.FDuckDictionaryWrapper.SetObject(AObj);
    end;
  end
  else
  begin
    Result := TdjTypeInfoCacheItem.Create;
    if TdjFactory.TryWrapAsDuckList(AObj, Result.FDuckListWrapper) then
      Result.FDuckType := TdjDuckType.dtList
    else if TdjFactory.TryWrapAsDuckStreamable(AObj, Result.FDuckStreamableWrapper) then
      Result.FDuckType := TdjDuckType.dtStreamable
    else if TdjFactory.TryWrapAsDuckDictionary(AObj, Result.FDuckDictionaryWrapper) then
      Result.FDuckType := TdjDuckType.dtDictionary
    else
      Result.FDuckType := TdjDuckType.dtNone;
    FInternatContainer.Add(AObj.ClassName, Result);
  end;
end;

end.
