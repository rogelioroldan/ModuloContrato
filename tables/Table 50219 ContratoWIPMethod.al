table 50219 "Contrato WIP Method"
{
    Caption = 'Contrato WIP Method';
    DrillDownPageID = "Contrato WIP Methods";
    LookupPageID = "Contrato WIP Methods";
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Code"; Code[20])
        {
            Caption = 'Code';
            NotBlank = true;

            trigger OnValidate()
            begin
                ValidateModification();
            end;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';

            trigger OnValidate()
            begin
                ValidateModification();
            end;
        }
        field(3; "WIP Cost"; Boolean)
        {
            Caption = 'WIP Cost';
            InitValue = true;

            trigger OnValidate()
            begin
                ValidateModification();
                if "Recognized Costs" <> "Recognized Costs"::"Usage (Total Cost)" then
                    Error(Text003, FieldCaption("Recognized Costs"), "Recognized Costs");
            end;
        }
        field(4; "WIP Sales"; Boolean)
        {
            Caption = 'WIP Sales';
            InitValue = true;

            trigger OnValidate()
            begin
                ValidateModification();
                if "Recognized Sales" <> "Recognized Sales"::"Contract (Invoiced Price)" then
                    Error(Text003, FieldCaption("Recognized Sales"), "Recognized Sales");
            end;
        }
        field(5; "Recognized Costs"; Enum "ContratoWIPRecognizedCostsType")
        {
            Caption = 'Recognized Costs';

            trigger OnValidate()
            begin
                ValidateModification();
                if "Recognized Costs" <> "Recognized Costs"::"Usage (Total Cost)" then
                    "WIP Cost" := true;
            end;
        }
        field(6; "Recognized Sales"; Enum "ContratWIPRecognizedSalesType")
        {
            Caption = 'Recognized Sales';

            trigger OnValidate()
            begin
                ValidateModification();
                if "Recognized Sales" <> "Recognized Sales"::"Contract (Invoiced Price)" then
                    "WIP Sales" := true;
            end;
        }
        field(7; Valid; Boolean)
        {
            Caption = 'Valid';
            InitValue = true;

            trigger OnValidate()
            var
                ContratosSetup: Record "Contratos Setup";
            begin
                ContratosSetup.SetRange("Default WIP Method", Code);
                if not ContratosSetup.IsEmpty() then
                    Error(Text007, ContratosSetup.FieldCaption("Default WIP Method"));
            end;
        }
        field(8; "System Defined"; Boolean)
        {
            Caption = 'System Defined';
            Editable = false;
            InitValue = false;
        }
        field(9; "System-Defined Index"; Integer)
        {
            Caption = 'System-Defined Index';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Code")
        {
            Clustered = true;
        }
        key(Key2; Valid)
        {
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    var
        ContratoWIPEntry: Record "Contrato WIP Entry";
        ContratoWIPGLEntry: Record "Contrato WIP G/L Entry";
        ContratosSetup: Record "Contratos Setup";
    begin
        if "System Defined" then
            Error(Text001, FieldCaption("System Defined"));

        ContratoWIPEntry.SetRange("WIP Method Used", Code);
        ContratoWIPGLEntry.SetRange("WIP Method Used", Code);
        if not (ContratoWIPEntry.IsEmpty() and ContratoWIPGLEntry.IsEmpty) then
            Error(Text004, ContratoWIPEntry.TableCaption(), ContratoWIPGLEntry.TableCaption());

        ContratosSetup.SetRange("Default WIP Method", Code);
        if not ContratosSetup.IsEmpty() then
            Error(Text006);
    end;

    var
        Text001: Label 'You cannot delete methods that are %1.';
        Text002: Label 'You cannot modify methods that are %1.';
        Text003: Label 'You cannot modify this field when %1 is %2.';
        Text004: Label 'You cannot delete methods that have entries in %1 or %2.';
        Text005: Label 'You cannot modify methods that have entries in %1 or %2.';
        Text006: Label 'You cannot delete the default method.';
        Text007: Label 'This method must be valid because it is defined as the %1.';

    local procedure ValidateModification()
    var
        ContratoWIPEntry: Record "Contrato WIP Entry";
        ContratoWIPGLEntry: Record "Contrato WIP G/L Entry";
    begin
        if "System Defined" then
            Error(Text002, FieldCaption("System Defined"));
        ContratoWIPEntry.SetRange("WIP Method Used", Code);
        ContratoWIPGLEntry.SetRange("WIP Method Used", Code);
        if not (ContratoWIPEntry.IsEmpty() and ContratoWIPGLEntry.IsEmpty) then
            Error(Text005, ContratoWIPEntry.TableCaption(), ContratoWIPGLEntry.TableCaption());
    end;
}

