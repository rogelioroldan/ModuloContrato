page 50220 "Contrato Task List"
{
    Caption = 'Contrato Task List';
    CardPageID = "Contrato Task Card";
    DataCaptionFields = "Contrato No.";
    Editable = false;
    PageType = List;
    SourceTable = "Contrato Task";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Contrato No."; Rec."Contrato No.")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    ToolTip = 'Specifies the number of the related Contrato.';
                }
                field("Contrato Task No."; Rec."Contrato Task No.")
                {
                    ApplicationArea = All;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    ToolTip = 'Specifies the number of the related Contrato task.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a description of the Contrato task. You can enter anything that is meaningful in describing the task. The description is copied and used in descriptions on the Contrato planning line.';
                }
                field("Contrato Task Type"; Rec."Contrato Task Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the purpose of the account. Newly created accounts are automatically assigned the Posting account type, but you can change this. Choose the field to select one of the following five options:';
                }
                field("WIP-Total"; Rec."WIP-Total")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Contrato tasks you want to group together when calculating Work In Process (WIP) and Recognition.';
                }
                field(Totaling; Rec.Totaling)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies an interval or a list of Contrato task numbers.';
                }
                field("Contrato Posting Group"; Rec."Contrato Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the Contrato posting group of the task.';
                }
#if not CLEAN25
                field("Coupled to Dataverse"; Rec."Coupled to Dataverse")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if the Contrato task is coupled to an entity in Field Service.';
                    Visible = false;
                    ObsoleteReason = 'Field Service is moved to Field Service Integration app.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '25.0';
                }
#endif
            }
        }
        area(factboxes)
        {
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
                Visible = false;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Contrato Task")
            {
                Caption = '&Contrato Task';
                Image = Task;
                group(Dimensions)
                {
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    action("Dimensions-Single")
                    {
                        ApplicationArea = Dimensions;
                        Caption = 'Dimensions-Single';
                        Image = Dimensions;
                        RunObject = Page "Contrato Task Dimensions";
                        RunPageLink = "Contrato No." = field("Contrato No."),
                                      "Contrato Task No." = field("Contrato Task No.");
                        ShortCutKey = 'Alt+D';
                        ToolTip = 'View or edit the single set of dimensions that are set up for the selected record.';
                    }
                    action("Dimensions-Multiple")
                    {
                        AccessByPermission = TableData Dimension = R;
                        ApplicationArea = Dimensions;
                        Caption = 'Dimensions-Multiple';
                        Image = DimensionSets;
                        ToolTip = 'View or edit dimensions for a group of records. You can assign dimension codes to transactions to distribute costs and analyze historical information.';

                        trigger OnAction()
                        var
                            ContratoTask: Record "Contrato Task";
                            ContratoTaskDimensionsMultiple: Page ContratoTaskDimensionsMultiple;
                        begin
                            CurrPage.SetSelectionFilter(ContratoTask);
                            ContratoTaskDimensionsMultiple.SetMultiContratoTask(ContratoTask);
                            ContratoTaskDimensionsMultiple.RunModal();
                        end;
                    }
                }
                action(ContratoTaskStatistics)
                {
                    ApplicationArea = All;
                    Caption = 'Statistics';
                    Image = StatisticsDocument;
                    RunObject = Page "Contrato Task Statistics";
                    RunPageLink = "Contrato No." = field("Contrato No."),
                                  "Contrato Task No." = field("Contrato Task No.");
                    ToolTip = 'View statistics for the Contrato task.';
                }
            }
#if not CLEAN25
            group(ActionGroupFS)
            {
                Caption = 'Dynamics 365 Field Service';
                Visible = false;
                ObsoleteReason = 'Field Service is moved to Field Service Integration app.';
                ObsoleteState = Pending;
                ObsoleteTag = '25.0';

                action(CRMGoToProduct)
                {
                    ApplicationArea = Suite;
                    Caption = 'Contrato Task in Field Service';
                    Image = CoupledItem;
                    ToolTip = 'Open the coupled Dynamics 365 Field Service entity.';
                    ObsoleteReason = 'Field Service is moved to Field Service Integration app.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '25.0';

                    trigger OnAction()
                    var
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                    begin
                        CRMIntegrationManagement.ShowCRMEntityFromRecordID(Rec.RecordId);
                    end;
                }
                action(CRMSynchronizeNow)
                {
                    AccessByPermission = TableData "CRM Integration Record" = IM;
                    ApplicationArea = Suite;
                    Caption = 'Synchronize';
                    Image = Refresh;
                    ToolTip = 'Send updated data to Dynamics 365 Field Service.';
                    ObsoleteReason = 'Field Service is moved to Field Service Integration app.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '25.0';

                    trigger OnAction()
                    var
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                    begin
                        CRMIntegrationManagement.UpdateOneNow(Rec.RecordId);
                    end;
                }
                group(Coupling)
                {
                    Caption = 'Coupling', Comment = 'Coupling is a noun';
                    Image = LinkAccount;
                    ToolTip = 'Create, change, or delete a coupling between the Business Central record and a Dynamics 365 Field Service entity.';
                    ObsoleteReason = 'Field Service is moved to Field Service Integration app.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '25.0';

                    action(ManageCRMCoupling)
                    {
                        AccessByPermission = TableData "CRM Integration Record" = IM;
                        ApplicationArea = Suite;
                        Caption = 'Set Up Coupling';
                        Image = LinkAccount;
                        ToolTip = 'Create or modify the coupling to a Dynamics 365 Field Service entity.';
                        ObsoleteReason = 'Field Service is moved to Field Service Integration app.';
                        ObsoleteState = Pending;
                        ObsoleteTag = '25.0';

                        trigger OnAction()
                        var
                            CRMIntegrationManagement: Codeunit "CRM Integration Management";
                        begin
                            CRMIntegrationManagement.DefineCoupling(Rec.RecordId);
                        end;
                    }
                    action(DeleteCRMCoupling)
                    {
                        AccessByPermission = TableData "CRM Integration Record" = D;
                        ApplicationArea = Suite;
                        Caption = 'Delete Coupling';
                        Enabled = false;
                        Image = UnLinkAccount;
                        ToolTip = 'Delete the coupling to a Dynamics 365 Field Service entity.';
                        ObsoleteReason = 'Field Service is moved to Field Service Integration app.';
                        ObsoleteState = Pending;
                        ObsoleteTag = '25.0';

                        trigger OnAction()
                        var
                            CRMCouplingManagement: Codeunit "CRM Coupling Management";
                        begin
                            CRMCouplingManagement.RemoveCoupling(Rec.RecordId);
                        end;
                    }
                }
                action(ShowLog)
                {
                    ApplicationArea = Suite;
                    Caption = 'Synchronization Log';
                    Image = Log;
                    ToolTip = 'View integration synchronization Contratos for this table.';
                    ObsoleteReason = 'Field Service is moved to Field Service Integration app.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '25.0';

                    trigger OnAction()
                    var
                        CRMIntegrationManagement: Codeunit "CRM Integration Management";
                    begin
                        CRMIntegrationManagement.ShowLog(Rec.RecordId);
                    end;
                }
            }
#endif
        }
        area(processing)
        {
            action("Split Planning Lines")
            {
                ApplicationArea = All;
                Caption = 'Split Planning Lines';
                Image = Splitlines;
                RunObject = Report "Contrato Split Planning Line";
                ToolTip = 'Split planning lines of type Budget and Billable into two separate planning lines: Budget and Billable.';
            }
            action("Change Planning Line Dates")
            {
                ApplicationArea = All;
                Caption = 'Change Planning Line Dates';
                Image = ChangeDates;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = Process;
                RunObject = Report "Change Contrato Dates";
                ToolTip = 'Use a batch Contrato to help you move planning lines on a Contrato from one date interval to another.';
            }
            action("Copy Contrato Task From")
            {
                ApplicationArea = All;
                Caption = 'Copy Contrato Task From';
                Ellipsis = true;
                Image = CopyFromTask;
                ToolTip = 'Use a batch Contrato to help you copy Contrato task lines and Contrato planning lines from one Contrato task to another. You can copy from a Contrato task within the Contrato you are working with or from a Contrato task linked to a different Contrato.';

                trigger OnAction()
                var
                    Contrato: Record Contrato;
                    CopyContratoTasks: Page "Copy Contrato Tasks";
                begin
                    if Contrato.Get(Rec."Contrato No.") then begin
                        CopyContratoTasks.SetToContrato(Contrato);
                        CopyContratoTasks.RunModal();
                    end;
                end;
            }
            action("Copy Contrato Task To")
            {
                ApplicationArea = All;
                Caption = 'Copy Contrato Task To';
                Ellipsis = true;
                Image = CopyToTask;
                ToolTip = 'Use a batch Contrato to help you copy Contrato task lines and Contrato planning lines from one Contrato task to another. You can copy from a Contrato task within the Contrato you are working with or from a Contrato task linked to a different Contrato.';

                trigger OnAction()
                var
                    Contrato: Record Contrato;
                    CopyContratoTasks: Page "Copy Contrato Tasks";
                begin
                    if Contrato.Get(Rec."Contrato No.") then begin
                        CopyContratoTasks.SetFromContrato(Contrato);
                        CopyContratoTasks.RunModal();
                    end;
                end;
            }
        }
        area(reporting)
        {
            action("Contrato Actual to Budget (Cost)")
            {
                ApplicationArea = All;
                Caption = 'Contrato Actual to Budget (Cost)';
                Image = "Report";
                RunObject = Report "ContratoActualtoBudget(Cost)";
                ToolTip = 'Compare budgeted and usage amounts for selected Contratos. All lines of the selected Contrato show quantity, total cost, and line amount.';
            }
            action("<Report Contrato Actual to Budget (Price)>")
            {
                ApplicationArea = All;
                Caption = 'Contrato Actual to Budget (Price)';
                Image = "Report";
                RunObject = Report "ContratoActualtoBudget(Price)";
                ToolTip = 'Compare the actual price of your Contratos to the price that was budgeted. The report shows budget and actual amounts for each phase, task, and steps.';
            }
            action("Contrato Analysis")
            {
                ApplicationArea = All;
                Caption = 'Contrato Analysis';
                Image = "Report";
                RunObject = Report "Contrato Analysis";
                ToolTip = 'Analyze the Contrato, such as the budgeted prices, usage prices, and billable prices, and then compares the three sets of prices.';
            }
            action("Contrato - Planning Lines")
            {
                ApplicationArea = All;
                Caption = 'Contrato - Planning Lines';
                Image = "Report";
                RunObject = Report "Contrato - Planning Lines";
                ToolTip = 'View all planning lines for the Contrato. You use this window to plan what items, resources, and general ledger expenses that you expect to use on a Contrato (budget) or you can specify what you actually agreed with your customer that he should pay for the Contrato (billable).';
            }
            action("Contrato - Suggested Billing")
            {
                ApplicationArea = All;
                Caption = 'Contrato - Suggested Billing';
                Image = "Report";
                RunObject = Report "ContratoCostSuggestedBilling";
                ToolTip = 'View a list of all Contratos, grouped by customer, how much the customer has already been invoiced, and how much remains to be invoiced, that is, the suggested billing.';
            }
            action("Contratos - Transaction Detail")
            {
                ApplicationArea = All;
                Caption = 'Contratos - Transaction Detail';
                Image = "Report";
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "ContratoCostTransactionDetail";
                ToolTip = 'View all postings with entries for a selected Contrato for a selected period, which have been charged to a certain Contrato. At the end of each Contrato list, the amounts are totaled separately for the Sales and Usage entry types.';
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref("Copy Contrato Task From_Promoted"; "Copy Contrato Task From")
                {
                }
                actionref("Copy Contrato Task To_Promoted"; "Copy Contrato Task To")
                {
                }
                group(Category_Dimensions)
                {
                    Caption = 'Dimensions';

                    actionref("Dimensions-Multiple_Promoted"; "Dimensions-Multiple")
                    {
                    }
                    actionref("Dimensions-Single_Promoted"; "Dimensions-Single")
                    {
                    }
                }
                actionref("Split Planning Lines_Promoted"; "Split Planning Lines")
                {
                }
                group(Category_Report)
                {
                    Caption = 'Reports';

                    actionref("Contrato Actual to Budget (Cost)_Promoted"; "Contrato Actual to Budget (Cost)")
                    {
                    }
                    actionref("<Report Contrato Actual to Budget (Price)>_Promoted"; "<Report Contrato Actual to Budget (Price)>")
                    {
                    }
                    actionref("Contrato Analysis_Promoted"; "Contrato Analysis")
                    {
                    }
                    actionref("Contrato - Planning Lines_Promoted"; "Contrato - Planning Lines")
                    {
                    }
                    actionref("Contrato - Suggested Billing_Promoted"; "Contrato - Suggested Billing")
                    {
                    }
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        StyleIsStrong := Rec."Contrato Task Type" <> Rec."Contrato Task Type"::Posting;
    end;

    var
        StyleIsStrong: Boolean;
}

