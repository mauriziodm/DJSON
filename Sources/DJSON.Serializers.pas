{***************************************************************************}
{                                                                           }
{           DJSON - (Delphi JSON library)                                   }
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
{  This file is part of DJSON (Delphi JSON library).                        }
{                                                                           }
{  Licensed under the GNU Lesser General Public License, Version 3;         }
{  you may not use this file except in compliance with the License.         }
{                                                                           }
{  DJSON is free software: you can redistribute it and/or modify            }
{  it under the terms of the GNU Lesser General Public License as published }
{  by the Free Software Foundation, either version 3 of the License, or     }
{  (at your option) any later version.                                      }
{                                                                           }
{  DJSON is distributed in the hope that it will be useful,                 }
{  but WITHOUT ANY WARRANTY; without even the implied warranty of           }
{  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            }
{  GNU Lesser General Public License for more details.                      }
{                                                                           }
{  You should have received a copy of the GNU Lesser General Public License }
{  along with DJSON.  If not, see <http://www.gnu.org/licenses/>.           }
{                                                                           }
{***************************************************************************}
{                                                                           }
{  This project is based off of the ObjectsMappers unit included with the   }
{  Delphi MVC Framework project by Daniele Teti and the DMVCFramework Team. }
{                                                                           }
{***************************************************************************}

unit DJSON.Serializers;

{$I DJSON.inc}

interface

uses
  System.Rtti,
  System.JSON,
{$IFDEF ENGINE_STREAM}
  System.JSON.Writers,
  System.JSON.Readers,
{$ENDIF}
  JsonDataObjects;

type
  TdjDOMCustomSerializerRef = class of TdjDOMCustomSerializer;

  TdjDOMCustomSerializer = class abstract
  public
    class function Serialize(const AValue: TValue): TJSONValue; virtual;
    class function Deserialize(const AJSONValue: TJSONValue; const AExistingValue: TValue): TValue; virtual;
    class function isTypeNotificationCompatible: Boolean; virtual;
  end;

  TdjJDOCustomSerializerRef = class of TdjJDOCustomSerializer;

  TdjJDOCustomSerializer = class abstract
  public
    class procedure Serialize(const AJSONValue: PJsonDataValue; const AValue: TValue); virtual;
    class function Deserialize(const AJSONValue: PJsonDataValue; const AExistingValue: TValue): TValue; virtual;
    class function isTypeNotificationCompatible: Boolean; virtual;
  end;
{$IFDEF ENGINE_STREAM}
  TdjStreamCustomSerializerRef = class of TdjStreamCustomSerializer;

  TdjStreamCustomSerializer = class abstract
  public
    class procedure Serialize(const AJSONWriter: TJSONWriter; const AValue: TValue); virtual;
    class function Deserialize(const AJSONReader: TJSONReader; const AExistingValue: TValue): TValue; virtual;
    class function isTypeNotificationCompatible: Boolean; virtual;
  end;
{$ENDIF}
//  TdjXMLCustomSerializerRef = class of TdjXMLCustomSerializer;
//  TdjXMLCustomSerializer = class abstract
//  public
//    class function Serialize(const AXMLNode:IXMLDOMNode; const AValue:TValue): TJSONValue; virtual;
//    class function Deserialize(const AXMLNode:IXMLDOMNode; const AExistingValue:TValue): TValue; virtual;
//    class function isTypeNotificationCompatible: Boolean; virtual;
//  end;

implementation

{ TdjCustomSerializer }

class function TdjDOMCustomSerializer.Deserialize(const AJSONValue: TJSONValue; const AExistingValue: TValue): TValue;
begin
  // None
  Result := nil;
end;

class function TdjDOMCustomSerializer.isTypeNotificationCompatible: Boolean;
begin
  // TypeNotification not compatible by default
  Result := False;
end;

class function TdjDOMCustomSerializer.Serialize(
  const AValue: TValue): TJSONValue;
begin
  // None
  Result := nil;
end;

{$IFDEF ENGINE_STREAM}

{ TdjStreamCustomSerializer }

class function TdjStreamCustomSerializer.Deserialize(const AJSONReader: TJSONReader; const AExistingValue: TValue): TValue;
begin
  // None
  Result := nil;
end;

class function TdjStreamCustomSerializer.isTypeNotificationCompatible: Boolean;
begin
  // TypeNotification not compatible by default
  Result := False;
end;

class procedure TdjStreamCustomSerializer.Serialize(const AJSONWriter: TJSONWriter; const AValue: TValue);
begin
  // None
end;
{$ENDIF}


{ TdjJDOCustomSerializer }

class function TdjJDOCustomSerializer.Deserialize(const AJSONValue: PJsonDataValue; const AExistingValue: TValue): TValue;
begin
  // None
  Result := nil;
end;

class function TdjJDOCustomSerializer.isTypeNotificationCompatible: Boolean;
begin
  // TypeNotification not compatible by default
  Result := False;
end;

class procedure TdjJDOCustomSerializer.Serialize(const AJSONValue: PJsonDataValue; const AValue: TValue);
begin
  // None
end;

end.

