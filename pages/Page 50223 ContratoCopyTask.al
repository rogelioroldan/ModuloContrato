page 50223 "Copy Contrato Tasks"
{
    Caption = 'Copy contrato Tasks';
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
                    ApplicationArea = All;
                    Caption = 'contrato No.';
                    TableRelation = Contrato;
                    ToolTip = 'Specifies the contrato number.';

                    trigger OnValidate()
                    begin
                        if (SourceContratoNo <> '') and not SourceContrato.Get(SourceContratoNo) then
                            Error(Text003, SourceContrato.TableCaption(), SourceContratoNo);

                        FromContratoTaskNo := '';
                        ToContratoTaskNo := '';
                    end;
                }
                field(FromContratoTaskNo; FromContratoTaskNo)
                {
                    ApplicationArea = All;
                    Caption = 'contrato Task No. from';
                    ToolTip = 'Specifies the first contrato task number to be copied from. Only planning lines with a contrato task number equal to or higher than the number specified in this field will be included.';

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
                    ApplicationArea = All;
                    Caption = 'contrato Task No. to';
                    ToolTip = 'Specifies the last contrato task number to be copied from. Only planning lines with a contrato task number equal to or lower than the number specified in this field will be included.';

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
                    ApplicationArea = All;
                    Caption = 'Source';
                    OptionCaption = 'contrato Planning Lines,contrato Ledger Entries,None';
                    ToolTip = 'Specifies the basis on which you want the planning lines to be copied. If, for example, you want the planning lines to reflect actual usage and invoicing of items, resources, and general ledger expenses on the contrato you copy from, then select contrato Ledger Entries in this field.';

                    trigger OnValidate()
                    begin
                        ValidateSource();
                    end;
                }
                field("Planning Line Type"; PlanningLineType)
                {
                    ApplicationArea = All;
                    Caption = 'Incl. Planning Line Type';
                    Enabled = PlanningLineTypeEnable;
                    OptionCaption = 'Budget+Billable,Budget,Billable';
                    ToolTip = 'Specifies how copy planning lines. Budget+Billable: All planning lines are copied. Budget: Only lines of type Budget or type Both Budget and Billable are copied. Billable: Only lines of type Billable or type Both Budget and Billable are copied.';
                }
                field("Ledger Entry Line Type"; LedgerEntryType)
                {
                    ApplicationArea = All;
                    Caption = 'Incl. Ledger Entry Line Type';
                    Enabled = LedgerEntryLineTypeEnable;
                    OptionCaption = 'Usage+Sale,Usage,Sale';
                    ToolTip = 'Specifies how to copy contrato ledger entries. Usage+Sale: All contrato ledger entries are copied. Entries of type Usage are copied to new planning lines of type Budget. Entries of type Sale are copied to new planning lines of type Billable. Usage: All contrato ledger entries of type Usage are copied to new planning lines of type Budget. Sale: All contrato ledger entries of type Sale are copied to new planning lines of type Billable.';
                }
                field(FromDate; FromDate)
                {
                    ApplicationArea = All;
                    Caption = 'Starting Date';
                    ToolTip = 'Specifies the date from which the report or batch Contrato processes information.';
                }
                field(ToDate; ToDate)
                {
                    ApplicationArea = All;
                    Caption = 'Ending Date';
                    ToolTip = 'Specifies the date to which the report or batch Contrato processes information.';
                }
            }
            group("Copy to")
            {
                Caption = 'Copy to';
                field(TargetContratoNo; TargetContratoNo)
                {
                    ApplicationArea = All;
                    Caption = 'contrato No.';
                    TableRelation = Contrato;
                    ToolTip = 'Specifies the contrato number.';

                    trigger OnValidate()
                    begin
                        if (TargetContratoNo <> '') and not TargetContrato.Get(TargetContratoNo) then
                            Error(Text003, TargetContrato.TableCaption(), TargetContratoNo);
                    end;
                }
            }
            group(Apply)
            {
                Caption = 'Apply';
                field(CopyQuantity; CopyQuantity)
                {
                    ApplicationArea = All;
                    Caption = 'Copy Quantity';
                    ToolTip = 'Specifies that the quantities will be copied to the new contrato.';
                }
                field(CopyDimensions; CopyDimensions)
                {
                    ApplicationArea = Dimensions;
                    Caption = 'Copy Dimensions';
                    ToolTip = 'Specifies that the dimensions will be copied to the new contrato task.';
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
        OnOpenPageOnBeforeValidateSource(CopyQuantity, CopyDimensions, Source, PlanningLineType, LedgerEntryType);
        ValidateSource();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOnQueryClosePage(CloseAction, SourceContrato, TargetContrato, IsHandled, CopyQuantity, CopyDimensions, Source, PlanningLineType, LedgerEntryType, FromContratoTaskNo, ToContratoTaskNo, FromDate, ToDate);
        if IsHandled then
            exit(IsHandled);

        if CloseAction in [ACTION::OK, ACTION::LookupOK] then begin
            ValidateUserInput();
            CopyContrato.SetCopyOptions(false, CopyQuantity, CopyDimensions, Source, PlanningLineType, LedgerEntryType);
            CopyContrato.SetContratoTaskRange(FromContratoTaskNo, ToContratoTaskNo);
            CopyContrato.SetContratoTaskDateRange(FromDate, ToDate);
            OnQueryClosePageOnBeforeCopyContratoTasks(CopyContrato, CopyQuantity, CopyDimensions, Source, PlanningLineType, LedgerEntryType);
            CopyContrato.CopyContratoTasks(SourceContrato, TargetContrato);
            Message(Text001);
        end
    end;

    var
        Text001: Label 'The contrato was successfully copied.';
        Text003: Label '%1 %2 does not exist.', Comment = 'contrato Task 1000 does not exist.';
        PlanningLineTypeEnable: Boolean;
        LedgerEntryLineTypeEnable: Boolean;
        Text004: Label 'Provide a valid source %1.';
        Text005: Label 'Provide a valid target %1.';

    protected var
        SourceContrato, TargetContrato : Record Contrato;
        CopyContrato: Codeunit "Copy Contrato";
        SourceContratoNo, FromContratoTaskNo, ToContratoTaskNo, TargetContratoNo : Code[20];
        FromDate, ToDate : Date;
        Source: Option "Contrato Planning Lines","Contrato Ledger Entries","None";
        PlanningLineType: Option "Budget+Billable",Budget,Billable;
        LedgerEntryType: Option "Usage+Sale",Usage,Sale;
        CopyQuantity, CopyDimensions : Boolean;

    local procedure ValidateUserInput()
    begin
        if (SourceContratoNo = '') or not SourceContrato.Get(SourceContratoNo) then
            Error(Text004, SourceContrato.TableCaption());

        if (TargetContratoNo = '') or not TargetContrato.Get(TargetContratoNo) then
            Error(Text005, TargetContrato.TableCaption());
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
    end;

    procedure SetToContrato(TargetContrato2: Record Contrato)
    begin
        TargetContrato := TargetContrato2;
        TargetContratoNo := TargetContrato."No.";
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
    local procedure OnBeforeOnQueryClosePage(var CloseAction: Action; var SourceContrato: Record Contrato; var TargetContrato: Record Contrato; var IsHandled: Boolean; var CopyQuantity: Boolean; var CopyDimensions: Boolean; var Source: Option "Contrato Planning Lines","Contrato Ledger Entries","None"; var PlanningLineType: Option "Budget+Billable",Budget,Billable; var LedgerEntryType: Option "Usage+Sale",Usage,Sale; var FromContratoTaskNo: Code[20]; var ToContratoTaskNo: Code[20]; var FromDate: Date; var ToDate: Date)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnOpenPageOnBeforeValidateSource(var CopyQuantity: Boolean; var CopyDimensions: Boolean; var Source: Option "Contrato Planning Lines","Contrato Ledger Entries","None"; var PlanningLineType: Option "Budget+Billable",Budget,Billable; var LedgerEntryType: Option "Usage+Sale",Usage,Sale);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnQueryClosePageOnBeforeCopyContratoTasks(var CopyContrato: Codeunit "Copy Contrato"; var CopyQuantity: Boolean; var CopyDimensions: Boolean; var Source: Option "Contrato Planning Lines","Contrato Ledger Entries","None"; var PlanningLineType: Option "Budget+Billable",Budget,Billable; var LedgerEntryType: Option "Usage+Sale",Usage,Sale);
    begin
    end;
}

