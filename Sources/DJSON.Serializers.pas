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



unit DJSON.Serializers;

interface

uses
  System.Rtti, System.JSON;

type

  TdjCustomSerializerRef = class of TdjCustomSerializer;

  TdjCustomSerializer = class abstract
  public
    class function Serialize(const AValue:TValue; var ADone:Boolean): TJSONValue; virtual;
    class function Deserialize(const AJSONValue:TJSONValue; const AExistingValue:TValue; var ADone:Boolean): TValue; virtual;
    class function isTypeNotificationCompatible: Boolean; virtual;
  end;

implementation

{ TdjCustomSerializer }

class function TdjCustomSerializer.Deserialize(const AJSONValue: TJSONValue;
  const AExistingValue: TValue; var ADone: Boolean): TValue;
begin
  // None
end;

class function TdjCustomSerializer.isTypeNotificationCompatible: Boolean;
begin
  // TypeNotification not compatible by default
  Result := False;
end;

class function TdjCustomSerializer.Serialize(const AValue: TValue;
  var ADone: Boolean): TJSONValue;
begin
  // None
end;

end.
