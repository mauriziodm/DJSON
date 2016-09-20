{***************************************************************************}
{                                                                           }
{           DJSON - (Delphi JSON library)                                    }
{                                                                           }
{           Copyright (C) 2016 Maurizio Del Magno                           }
{                                                                           }
{           mauriziodm@levantesw.it                                         }
{           mauriziodelmagno@gmail.com                                      }
{           https://github.com/mauriziodm/DSON.git                          }
{                                                                           }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  Licensed under the Apache License, Version 2.0 (the "License");          }
{  you may not use this file except in compliance with the License.         }
{  You may obtain a copy of the License at                                  }
{                                                                           }
{      http://www.apache.org/licenses/LICENSE-2.0                           }
{                                                                           }
{  Unless required by applicable law or agreed to in writing, software      }
{  distributed under the License is distributed on an "AS IS" BASIS,        }
{  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. }
{  See the License for the specific language governing permissions and      }
{  limitations under the License.                                           }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  This project is based off of the ObjectsMappers unit included with the   }
{  Delphi MVC Framework project by Daniele Teti and the DMVCFramework Team. }
{                                                                           }
{***************************************************************************}



unit DJSON.Factory;

interface

uses
  DJSON.Params, DJSON.Duck.Interfaces;

type

  TdjFactory = class
  public
    class function NewParams: IdjParams;
    class function TryWrapAsDuckStreamable(const AObjAsDuck: TObject; out ResultDuckStreamable:IdjDuckStreamable): Boolean;
    class function TryWrapAsDuckList(const AObjAsDuck: TObject; out ResultDuckList:IdjDuckList): Boolean;
    class function TryWrapAsDuckDictionary(const AObjAsDuck: TObject; out ResultDuckDictionary:IdjDuckDictionary): Boolean;
  end;

implementation

uses
  DJSON.Duck.Dictionary, DJSON.Duck.List, DJSON.Duck.Obj;

{ TdjFactory }

class function TdjFactory.NewParams: IdjParams;
begin
  Result := TdjParams.Create;
end;

class function TdjFactory.TryWrapAsDuckDictionary(const AObjAsDuck: TObject;
  out ResultDuckDictionary: IdjDuckDictionary): Boolean;
begin
  ResultDuckDictionary := TdjDuckDictionary.TryCreate(AObjAsDuck);
  Result := Assigned(ResultDuckDictionary);
end;

class function TdjFactory.TryWrapAsDuckList(const AObjAsDuck: TObject;
  out ResultDuckList: IdjDuckList): Boolean;
begin
  ResultDuckList := TdjDuckList.TryCreate(AObjAsDuck);
  Result := Assigned(ResultDuckList);
end;

class function TdjFactory.TryWrapAsDuckStreamable(const AObjAsDuck: TObject;
  out ResultDuckStreamable: IdjDuckStreamable): Boolean;
begin
  ResultDuckStreamable := TdjDuckStreamable.TryCreate(AObjAsDuck);
  Result := Assigned(ResultDuckStreamable);
end;

end.
