table 50214 "Contrato Task Dimension"
{
    Caption = 'Contrato Task Dimension';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Contrato No."; Code[20])
        {
            Caption = 'Contrato No.';
            Editable = false;
            NotBlank = true;
            TableRelation = "Contrato Task"."Contrato No.";
        }
        field(2; "Contrato Task No."; Code[20])
        {
            Caption = 'Contrato Task No.';
            NotBlank = true;
            TableRelation = "Contrato Task"."Contrato Task No." where("Contrato No." = field("Contrato No."));
        }
        field(3; "Dimension Code"; Code[20])
        {
            Caption = 'Dimension Code';
            TableRelation = Dimension.Code;

            trigger OnValidate()
            begin
                if not DimMgt.CheckDim("Dimension Code") then
                    Error(DimMgt.GetDimErr());
                "Dimension Value Code" := '';
            end;
        }
        field(4; "Dimension Value Code"; Code[20])
        {
            Caption = 'Dimension Value Code';
            TableRelation = "Dimension Value".Code where("Dimension Code" = field("Dimension Code"), Blocked = const(false));

            trigger OnValidate()
            begin
                if not DimMgt.CheckDimValue("Dimension Code", "Dimension Value Code") then
                    Error(DimMgt.GetDimErr());
            end;
        }
        field(5; "Multiple Selection Action"; Option)
        {
            Caption = 'Multiple Selection Action';
            OptionCaption = ' ,Change,Delete';
            OptionMembers = " ",Change,Delete;
        }
    }

    keys
    {
        key(Key1; "Contrato No.", "Contrato Task No.", "Dimension Code")
        {
            Clustered = true;
        }
        key(Key2; "Dimension Code")
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        UpdateGlobalDim('');
    end;

    trigger OnInsert()
    begin
        if "Dimension Value Code" = '' then
            Error(Text001, TableCaption);

        UpdateGlobalDim("Dimension Value Code");
    end;

    trigger OnModify()
    begin
        UpdateGlobalDim("Dimension Value Code");
    end;

    trigger OnRename()
    var
        IsHandled: Boolean;
    begin
        OnBeforeOnRename(Rec, IsHandled);
        if IsHandled then
            exit;

        Error(Text000, TableCaption);
    end;

    var
        DimMgt: Codeunit DimensionManagement;
        Text000: Label 'You cannot rename a %1.';
        Text001: Label 'At least one dimension value code must have a value. Enter a value or delete the %1. ';

    procedure UpdateGlobalDim(DimensionValue: Code[20])
    var
        ContratoTask: Record "Contrato Task";
        GLSEtup: Record "General Ledger Setup";
    begin
        GLSEtup.Get();
        if "Dimension Code" = GLSEtup."Global Dimension 1 Code" then begin
            ContratoTask.Get("Contrato No.", "Contrato Task No.");
            ContratoTask."Global Dimension 1 Code" := DimensionValue;
            ContratoTask.Modify(true);
        end else
            if "Dimension Code" = GLSEtup."Global Dimension 2 Code" then begin
                ContratoTask.Get("Contrato No.", "Contrato Task No.");
                ContratoTask."Global Dimension 2 Code" := DimensionValue;
                ContratoTask.Modify(true);
            end;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOnRename(var ContratoTaskDimension: Record "Contrato Task Dimension"; var IsHandled: Boolean)
    begin
    end;
}

