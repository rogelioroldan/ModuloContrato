page 50219 "Copy Contrato Planning Lines"
{
    Caption = 'Copy Project Planning Lines';
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
                    Caption = 'Project No.';
                    TableRelation = Contrato;
                    ToolTip = 'Specifies the project number.';

                    trigger OnValidate()
                    var
                        SourceContrato: Record Contrato;
                    begin
                        if (SourceContratoNo <> '') and not SourceContrato.Get(SourceContratoNo) then
                            Error(Text003, SourceContrato.TableCaption(), SourceContratoNo);

                        SourceContratoTaskNo := '';
                    end;
                }
                field(SourceContratoTaskNo; SourceContratoTaskNo)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Project Task No.';
                    ToolTip = 'Specifies the project task number.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ContratoTask: Record "Contrato Task";
                    begin
                        if SourceContratoNo <> '' then begin
                            ContratoTask.SetRange("Contrato No.", SourceContratoNo);
                            if PAGE.RunModal(PAGE::"Contrato Task List", ContratoTask) = ACTION::LookupOK then
                                SourceContratoTaskNo := ContratoTask."Contrato Task No.";
                        end;
                    end;

                    trigger OnValidate()
                    var
                        ContratoTask: Record "Contrato Task";
                    begin
                        if (SourceContratoTaskNo <> '') and not ContratoTask.Get(SourceContratoNo, SourceContratoTaskNo) then
                            Error(Text003, ContratoTask.TableCaption(), SourceContratoTaskNo);
                    end;
                }
                field("Planning Line Type"; PlanningLineType)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Incl. Planning Line Type';
                    OptionCaption = 'Budget+Billable,Budget,Billable';
                    ToolTip = 'Specifies how copy planning lines. Budget+Billable: All planning lines are copied. Budget: Only lines of type Budget or type Both Budget and Billable are copied. Billable: Only lines of type Billable or type Both Budget and Billable are copied.';
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
                    Caption = 'Project No.';
                    TableRelation = Contrato;
                    ToolTip = 'Specifies the project number.';

                    trigger OnValidate()
                    var
                        TargetContrato: Record Contrato;
                    begin
                        if (TargetContratoNo <> '') and not TargetContrato.Get(TargetContratoNo) then
                            Error(Text003, TargetContrato.TableCaption(), TargetContratoNo);

                        TargetContratoTaskNo := '';
                    end;
                }
                field(TargetContratoTaskNo; TargetContratoTaskNo)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Project Task No.';
                    ToolTip = 'Specifies the project task number.';

                    trigger OnLookup(var Text: Text): Boolean
                    var
                        ContratoTask: Record "Contrato Task";
                    begin
                        if TargetContratoNo <> '' then begin
                            ContratoTask.SetRange("Contrato No.", TargetContratoNo);
                            if PAGE.RunModal(PAGE::"Contrato Task List", ContratoTask) = ACTION::LookupOK then
                                TargetContratoTaskNo := ContratoTask."Contrato Task No.";
                        end;
                    end;

                    trigger OnValidate()
                    var
                        ContratoTask: Record "Contrato Task";
                    begin
                        if (TargetContratoTaskNo <> '') and not ContratoTask.Get(TargetContratoNo, TargetContratoTaskNo) then
                            Error(Text003, ContratoTask.TableCaption(), TargetContratoTaskNo);
                    end;
                }
            }
            group(Apply)
            {
                Caption = 'Apply';
                field(CopyQuantity; CopyQuantity)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Copy Quantity';
                    ToolTip = 'Specifies that the quantities will be copied to the new project.';
                }
                field(CopyContratoPrices; CopyContratoPrices)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Copy Project Prices';
                    ToolTip = 'Specifies that item prices, resource prices, and G/L prices will be copied from the project that you specified on the Copy From FastTab.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction in [ACTION::OK, ACTION::LookupOK] then begin
            ValidateUserInput();
            CopyContrato.SetCopyQuantity(CopyQuantity);
            CopyContrato.SetCopyPrices(CopyContratoPrices);
            CopyContrato.SetCopyContratoPlanningLineType(PlanningLineType);
            CopyContrato.SetContratoTaskDateRange(FromDate, ToDate);
            OnQueryClosePageOnBeforeCopyContratoPlanningLines(SourceContratoNo, SourceContratoTaskNo, PlanningLineType, FromDate, ToDate, TargetContratoNo, TargetContratoTaskNo, CopyQuantity);
            CopyContrato.CopyContratoPlanningLines(SourceContratoTask, TargetContratoTask);
            OnQueryClosePageOnAfterCopyContratoPlanningLines(SourceContratoTask, TargetContratoTask);
            Message(Text001);
        end
    end;

    var
        SourceContratoTask: Record "Contrato Task";
        TargetContratoTask: Record "Contrato Task";
        CopyContrato: Codeunit "Copy Contrato";
        SourceContratoNo: Code[20];
        SourceContratoTaskNo: Code[20];
        TargetContratoNo: Code[20];
        TargetContratoTaskNo: Code[20];
        Text001: Label 'The project was successfully copied.';
        Text003: Label '%1 %2 does not exist.', Comment = 'Project Task 1000 does not exist.';
        PlanningLineType: Option "Budget+Billable",Budget,Billable;
        FromDate: Date;
        ToDate: Date;
        CopyQuantity: Boolean;
        CopyContratoPrices: Boolean;
        Text004: Label 'Provide a valid source %1.';
        Text005: Label 'Provide a valid target %1.';

    local procedure ValidateUserInput()
    var
        Contrato: Record Contrato;
    begin
        if SourceContratoNo = '' then
            Error(Text004, Contrato.TableCaption());
        if (SourceContratoTaskNo = '') or not SourceContratoTask.Get(SourceContratoNo, SourceContratoTaskNo) then
            Error(Text004, SourceContratoTask.TableCaption());

        if TargetContratoNo = '' then
            Error(Text005, Contrato.TableCaption());
        if (TargetContratoTaskNo = '') or not TargetContratoTask.Get(TargetContratoNo, TargetContratoTaskNo) then
            Error(Text005, TargetContratoTask.TableCaption());
    end;

    procedure SetFromContratoTask(SourceContratoTask2: Record "Contrato Task")
    begin
        SourceContratoNo := SourceContratoTask2."Contrato No.";
        SourceContratoTask := SourceContratoTask2;
        SourceContratoTaskNo := SourceContratoTask2."Contrato Task No.";
    end;

    procedure SetToContratoTask(TargetContratoTask2: Record "Contrato Task")
    begin
        TargetContratoNo := TargetContratoTask2."Contrato No.";
        TargetContratoTask := TargetContratoTask2;
        TargetContratoTaskNo := TargetContratoTask2."Contrato Task No.";
    end;

    [IntegrationEvent(false, false)]
    local procedure OnQueryClosePageOnBeforeCopyContratoPlanningLines(SourceContratoNo: Code[20]; SourceContratoTaskNo: Code[20]; PlanningLineType: Option; FromDate: Date; ToDate: Date; TargetContratoNo: Code[20]; TargetContratoTaskNo: Code[20]; CopyQuantity: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnQueryClosePageOnAfterCopyContratoPlanningLines(SourceContratoTask: Record "Contrato Task"; TargetContratoTask: Record "Contrato Task")
    begin
    end;
}

