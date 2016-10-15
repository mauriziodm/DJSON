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
  System.Rtti, System.JSON, System.JSON.Writers, System.JSON.Readers,
  JsonDataObjects, MSXML;

type

  TdjDOMCustomSerializerRef = class of TdjDOMCustomSerializer;
  TdjDOMCustomSerializer = class abstract
  public
    class function Serialize(const AValue:TValue; var ADone:Boolean): TJSONValue; virtual;
    class function Deserialize(const AJSONValue:TJSONValue; const AExistingValue:TValue; var ADone:Boolean): TValue; virtual;
    class function isTypeNotificationCompatible: Boolean; virtual;
  end;

  TdjJDOCustomSerializerRef = class of TdjJDOCustomSerializer;
  TdjJDOCustomSerializer = class abstract
  public
    class procedure Serialize(const AResult:PJsonDataValue; const AValue:TValue; var ADone:Boolean); virtual;
    class function Deserialize(const AJSONValue:PJsonDataValue; const AExistingValue:TValue; var ADone:Boolean): TValue; virtual;
    class function isTypeNotificationCompatible: Boolean; virtual;
  end;

  TdjStreamCustomSerializerRef = class of TdjStreamCustomSerializer;
  TdjStreamCustomSerializer = class abstract
  public
    class procedure Serialize(const AJSONWriter: TJSONWriter; const AValue:TValue; var ADone:Boolean); virtual;
    class function Deserialize(const AJSONReader: TJSONReader; const AExistingValue:TValue; var ADone:Boolean): TValue; virtual;
    class function isTypeNotificationCompatible: Boolean; virtual;
  end;

  TdjXMLCustomSerializerRef = class of TdjXMLCustomSerializer;
  TdjXMLCustomSerializer = class abstract
  public
    class function Serialize(const AXMLNode:IXMLDOMNode; const AValue:TValue; var ADone:Boolean): TJSONValue; virtual;
    class function Deserialize(const AXMLNode:IXMLDOMNode; const AExistingValue:TValue; var ADone:Boolean): TValue; virtual;
    class function isTypeNotificationCompatible: Boolean; virtual;
  end;

implementation

{ TdjCustomSerializer }

class function TdjDOMCustomSerializer.Deserialize(const AJSONValue: TJSONValue;
  const AExistingValue: TValue; var ADone: Boolean): TValue;
begin
  // None
end;

class function TdjDOMCustomSerializer.isTypeNotificationCompatible: Boolean;
begin
  // TypeNotification not compatible by default
  Result := False;
end;

class function TdjDOMCustomSerializer.Serialize(const AValue: TValue;
  var ADone: Boolean): TJSONValue;
begin
  // None
end;

{ TdjStreamCustomSerializer }

class function TdjStreamCustomSerializer.Deserialize(
  const AJSONReader: TJSONReader; const AExistingValue: TValue;
  var ADone: Boolean): TValue;
begin
  // None
end;

class function TdjStreamCustomSerializer.isTypeNotificationCompatible: Boolean;
begin
  // TypeNotification not compatible by default
  Result := False;
end;

class procedure TdjStreamCustomSerializer.Serialize(
  const AJSONWriter: TJSONWriter; const AValue: TValue; var ADone: Boolean);
begin
  // None
end;

{ TdjJDOCustomSerializer }

class function TdjJDOCustomSerializer.Deserialize(
  const AJSONValue: PJsonDataValue; const AExistingValue: TValue;
  var ADone: Boolean): TValue;
begin
  // None
end;

class function TdjJDOCustomSerializer.isTypeNotificationCompatible: Boolean;
begin
  // TypeNotification not compatible by default
  Result := False;
end;

class procedure TdjJDOCustomSerializer.Serialize(const AResult: PJsonDataValue;
  const AValue: TValue; var ADone: Boolean);
begin
  // None
end;

{ TdjXMLCustomSerializer }

class function TdjXMLCustomSerializer.Deserialize(const AXMLNode: IXMLDOMNode;
  const AExistingValue: TValue; var ADone: Boolean): TValue;
begin
  // None
end;

class function TdjXMLCustomSerializer.isTypeNotificationCompatible: Boolean;
begin
  // TypeNotification not compatible by default
  Result := False;
end;

class function TdjXMLCustomSerializer.Serialize(const AXMLNode: IXMLDOMNode;
  const AValue: TValue; var ADone: Boolean): TJSONValue;
begin
  // None
end;

end.
