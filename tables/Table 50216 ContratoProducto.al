table 50216 "Contrato Producto"
{
    Caption = 'Contrato Producto';
    DataClassification = ToBeClassified;
    LookupPageId = "Contrato Producto Factura";
    DrillDownPageId = "Contrato Producto Factura";

    fields
    {
        field(1; "Código"; Code[20])
        {
            Caption = 'Código';
            NotBlank = true;
        }
        field(2; "Nombre"; Text[500])
        {
            Caption = 'Nombre';
        }
    }

    keys
    {
        key(Key1; "Código")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
    end;

    trigger OnInsert()
    begin
    end;

    trigger OnModify()
    begin
    end;

    trigger OnRename()
    var
        IsHandled: Boolean;
    begin
    end;

    var


}

