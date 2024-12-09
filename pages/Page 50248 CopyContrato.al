page 50248 "Copy Contrato"
{
    Caption = 'Copy Contrato';
    PageType = StandardDialog;

    layout
    {
        area(content)
        {
            group("Copy from")
            {
                Caption = 'Copy from';
                field(SourceContratoNo; SourceContratoNo)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Contrato No.';
                    TableRelation = Contrato;
                    ToolTip = 'Specifies the project number.';

                    trigger OnValidate()
                    begin
                        if (SourceContratoNo <> '') and not SourceContrato.Get(SourceContratoNo) then
                            Error(Text003, SourceContrato.TableCaption(), SourceContratoNo);
                        TargetContratoDescription := SourceContrato.Description;
                        TargetSellToCustomerNo := SourceContrato."Sell-to Customer No.";
                        TargetBillToCustomerNo := SourceContrato."Bill-to Customer No.";

                        FromContratoTaskNo := '';
                        ToContratoTaskNo := '';
                    end;
                }
                field(FromContratoTaskNo; FromContratoTaskNo)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Contrato Task No. from';
                    ToolTip = 'Specifies the first project task number to be copied from. Only planning lines with a project task number equal to or higher than the number specified in this field will be included.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ContratoTask: Record "Contrato Task";
                    begin
                        if SourceContrato."No." <> '' then begin
                            ContratoTask.SetRange("Contrato No.", SourceContrato."No.");
                            OnLookupFromContratoTaskNoOnAfterSetContratoTaskFilters(ContratoTask);
                            if PAGE.RunModal(PAGE::"Contrato Task List", ContratoTask) = ACTION::LookupOK then
                                FromContratoTaskNo := ContratoTask."Contrato Task No.";
                        end;
                    end;

                    trigger OnValidate()
                    var
                        ContratoTask: Record "Contrato Task";
                    begin
                        if (FromContratoTaskNo <> '') and not ContratoTask.Get(SourceContrato."No.", FromContratoTaskNo) then
                            Error(Text003, ContratoTask.TableCaption(), FromContratoTaskNo);
                    end;
                }
                field(ToContratoTaskNo; ToContratoTaskNo)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Contrato Task No. to';
                    ToolTip = 'Specifies the last project task number to be copied from. Only planning lines with a project task number equal to or lower than the number specified in this field will be included.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ContratoTask: Record "Contrato Task";
                    begin
                        if SourceContratoNo <> '' then begin
                            ContratoTask.SetRange("Contrato No.", SourceContratoNo);
                            OnLookupToContratoTaskNoOnAfterSetContratoTaskFilters(ContratoTask);
                            if PAGE.RunModal(PAGE::"Contrato Task List", ContratoTask) = ACTION::LookupOK then
                                ToContratoTaskNo := ContratoTask."Contrato Task No.";
                        end;
                    end;

                    trigger OnValidate()
                    var
                        ContratoTask: Record "Contrato Task";
                    begin
                        if (ToContratoTaskNo <> '') and not ContratoTask.Get(SourceContratoNo, ToContratoTaskNo) then
                            Error(Text003, ContratoTask.TableCaption(), ToContratoTaskNo);
                    end;
                }
                field("From Source"; Source)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Source';
                    OptionCaption = 'Contrato Planning Lines,Contrato Ledger Entries,None';
                    ToolTip = 'Specifies the basis on which you want the planning lines to be copied. If, for example, you want the planning lines to reflect actual usage and invoicing of items, resources, and general ledger expenses on the project you copy from, then select Contrato Ledger Entries in this field.';

                    trigger OnValidate()
                    begin
                        ValidateSource();
                    end;
                }
                field("Planning Line Type"; PlanningLineType)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Incl. Planning Line Type';
                    Enabled = PlanningLineTypeEnable;
                    OptionCaption = 'Budget+Billable,Budget,Billable';
                    ToolTip = 'Specifies how copy planning lines. Budget+Billable: All planning lines are copied. Budget: Only lines of type Budget or type Both Budget and Billable are copied. Billable: Only lines of type Billable or type Both Budget and Billable are copied.';
                }
                field("Ledger Entry Line Type"; LedgerEntryType)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Incl. Ledger Entry Line Type';
                    Enabled = LedgerEntryLineTypeEnable;
                    OptionCaption = 'Usage+Sale,Usage,Sale';
                    ToolTip = 'Specifies how to copy project ledger entries. Usage+Sale: All project ledger entries are copied. Entries of type Usage are copied to new planning lines of type Budget. Entries of type Sale are copied to new planning lines of type Billable. Usage: All project ledger entries of type Usage are copied to new planning lines of type Budget. Sale: All project ledger entries of type Sale are copied to new planning lines of type Billable.';
                }
                field(FromDate; FromDate)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Starting Date';
                    ToolTip = 'Specifies the date from which the report or batch Contrato processes information.';
                }
                field(ToDate; ToDate)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Ending Date';
                    ToolTip = 'Specifies the date to which the report or batch Contrato processes information.';
                }
            }
            group("Copy to")
            {
                Caption = 'Copy to';
                field(TargetContratoNo; TargetContratoNo)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Contrato No.';
                    ToolTip = 'Specifies the project number.';
                }
                field(TargetContratoDescription; TargetContratoDescription)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Contrato Description';
                    ToolTip = 'Specifies a description of the project.';
                }
                field(TargetSellToCustomerNo; TargetSellToCustomerNo)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Sell-To Customer No.';
                    TableRelation = Customer;
                    ToolTip = 'Specifies the number of an alternate customer that the project is sold to instead of the main customer.';
                }
                field(TargetBillToCustomerNo; TargetBillToCustomerNo)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Bill-To Customer No.';
                    TableRelation = Customer;
                    ToolTip = 'Specifies the number of an alternate customer that the project is billed to instead of the main customer.';
                }
            }
            group(Apply)
            {
                Caption = 'Apply';
                field(CopyContratoPrices; CopyContratoPrices)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Copy Contrato Prices';
                    ToolTip = 'Specifies that item prices, resource prices, and G/L prices will be copied from the project that you specified on the Copy From FastTab.';
                }
                field(CopyQuantity; CopyQuantity)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Copy Quantity';
                    ToolTip = 'Specifies that the quantities will be copied to the new project.';
                }
                field(CopyDimensions; CopyDimensions)
                {
                    ApplicationArea = Dimensions;
                    Caption = 'Copy Dimensions';
                    ToolTip = 'Specifies that the dimensions will be copied to the new project.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    begin
        PlanningLineType := PlanningLineType::"Budget+Billable";
        LedgerEntryType := LedgerEntryType::"Usage+Sale";
        ValidateSource();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        TargetContrato: Record Contrato;
    begin
        if CloseAction in [ACTION::OK, ACTION::LookupOK] then begin
            ValidateUserInput();
            CopyContrato.SetCopyOptions(CopyContratoPrices, CopyQuantity, CopyDimensions, Source, PlanningLineType, LedgerEntryType);
            CopyContrato.SetContratoTaskRange(FromContratoTaskNo, ToContratoTaskNo);
            CopyContrato.SetContratoTaskDateRange(FromDate, ToDate);
            CopyContrato.CopyContrato(SourceContrato, TargetContratoNo, TargetContratoDescription, TargetSellToCustomerNo, TargetBillToCustomerNo);
            TargetContrato.Get(TargetContratoNo);
            Message(Text001, SourceContrato."No.", TargetContrato."No.", TargetContrato.Status);
        end
    end;

    var
        CopyContrato: Codeunit "Copy Contrato";
        FromDate: Date;
        ToDate: Date;
        Source: Option "Contrato Planning Lines","Contrato Ledger Entries","None";
        PlanningLineType: Option "Budget+Billable",Budget,Billable;
        LedgerEntryType: Option "Usage+Sale",Usage,Sale;
        PlanningLineTypeEnable: Boolean;
        LedgerEntryLineTypeEnable: Boolean;

        Text001: Label 'The project no. %1 was successfully copied to the new project no. %2 with the status %3.', Comment = '%1 - The "No." of source project; %2 - The "No." of target project, %3 - project status.';
        Text002: Label 'Contrato No. %1 will be assigned to the new Contrato. Do you want to continue?';
        Text003: Label '%1 %2 does not exist.', Comment = 'Contrato Task 1000 does not exist.';
        Text004: Label 'Provide a valid source %1.';

    protected var
        SourceContrato: Record Contrato;
        SourceContratoNo: Code[20];
        FromContratoTaskNo: Code[20];
        ToContratoTaskNo: Code[20];
        TargetContratoNo: Code[20];
        TargetContratoDescription: Text[100];
        TargetSellToCustomerNo: Code[20];
        TargetBillToCustomerNo: Code[20];
        CopyContratoPrices: Boolean;
        CopyQuantity: Boolean;
        CopyDimensions: Boolean;

    local procedure ValidateUserInput()
    var
        ContratosSetup: Record "Contratos Setup";
        NoSeries: Codeunit "No. Series";
        IsHandled: Boolean;
    begin
        if (SourceContratoNo = '') or not SourceContrato.Get(SourceContrato."No.") then
            Error(Text004, SourceContrato.TableCaption());
        IsHandled := false;
        OnValidateUserInputOnBeforeCheckTargetContratoNo(SourceContrato, TargetContratoNo, IsHandled);
        if not IsHandled then begin
            ContratosSetup.Get();
            ContratosSetup.TestField("Contrato Nos.");
            if TargetContratoNo = '' then begin
                TargetContratoNo := NoSeries.GetNextNo(ContratosSetup."Contrato Nos.", 0D);
                if not Confirm(Text002, true, TargetContratoNo) then begin
                    TargetContratoNo := '';
                    Error('');
                end;
            end else
                NoSeries.TestManual(ContratosSetup."Contrato Nos.");
        end;
    end;

    local procedure ValidateSource()
    begin
        case true of
            Source = Source::"Contrato Planning Lines":
                begin
                    PlanningLineTypeEnable := true;
                    LedgerEntryLineTypeEnable := false;
                end;
            Source = Source::"Contrato Ledger Entries":
                begin
                    PlanningLineTypeEnable := false;
                    LedgerEntryLineTypeEnable := true;
                end;
            Source = Source::None:
                begin
                    PlanningLineTypeEnable := false;
                    LedgerEntryLineTypeEnable := false;
                end;
        end;
    end;

    procedure SetFromContrato(SourceContrato2: Record Contrato)
    begin
        SourceContrato := SourceContrato2;
        SourceContratoNo := SourceContrato."No.";
        TargetContratoDescription := SourceContrato.Description;
        TargetSellToCustomerNo := SourceContrato."Sell-to Customer No.";
        TargetBillToCustomerNo := SourceContrato."Bill-to Customer No.";

        OnAfterSetFromContrato(SourceContrato, FromDate, ToDate);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterSetFromContrato(SourceContrato: Record Contrato; var FromDate: Date; var ToDate: Date)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLookupFromContratoTaskNoOnAfterSetContratoTaskFilters(var ContratoTask: Record "Contrato Task")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnLookupToContratoTaskNoOnAfterSetContratoTaskFilters(var ContratoTask: Record "Contrato Task")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnValidateUserInputOnBeforeCheckTargetContratoNo(SourceContrato: Record Contrato; var TargetContratoNo: Code[20]; var IsHandled: Boolean)
    begin
    end;
}

