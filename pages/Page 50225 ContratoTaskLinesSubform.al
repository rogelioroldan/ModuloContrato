page 50206 "Contrato Task Lines Subform"
{
    Caption = 'Contrato Task Lines Subform';
    DataCaptionFields = "Contrato No.";
    PageType = ListPart;
    SaveValues = true;
    CardPageId = "Contrato Task Card";
    SourceTable = "Contrato Task";

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                IndentationColumn = DescriptionIndent;
                IndentationControls = Description;
                ShowCaption = false;
                field("Contrato No."; Rec."Contrato No.")
                {
                    ApplicationArea = Basic, Suite, Contratos;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    ToolTip = 'Specifies the number of the related Contrato.';
                    Visible = false;
                }
                field("Contrato Task No."; Rec."Contrato Task No.")
                {
                    ApplicationArea = Basic, Suite, Contratos;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    ToolTip = 'Specifies the number of the related Contrato task.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite, Contratos;
                    Style = Strong;
                    StyleExpr = StyleIsStrong;
                    ToolTip = 'Specifies a description of the Contrato task. You can enter anything that is meaningful in describing the task. The description is copied and used in descriptions on the Contrato planning line.';
                }
                field("Contrato Task Type"; Rec."Contrato Task Type")
                {
                    ApplicationArea = Basic, Suite, Contratos;
                    ToolTip = 'Specifies the purpose of the account. Newly created accounts are automatically assigned the Posting account type, but you can change this. Choose the field to select one of the following five options:';

                    trigger OnValidate()
                    begin
                        StyleIsStrong := Rec."Contrato Task Type" <> Rec."Contrato Task Type"::Posting;
                        CurrPage.Update();
                    end;
                }
                field(Totaling; Rec.Totaling)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies an interval or a list of Contrato task numbers.';
                    Visible = false;
                }
                field("Sell-to Customer No."; Rec."Sell-to Customer No.")
                {
                    ApplicationArea = Contratos;
                    Caption = 'Customer No.';
                    ToolTip = 'Specifies the number of the customer who will receive the products and be billed by default for the Contrato task.';
                    Visible = PerTaskBillingFieldsVisible;
                    Editable = PostingTypeRow;
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the number of the customer who pays for the Contrato task.';
                    Visible = PerTaskBillingFieldsVisible;
                    Editable = PostingTypeRow;
                }
                field("Contrato Posting Group"; Rec."Contrato Posting Group")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the Contrato posting group of the task.';
                    Visible = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the location code of the task.';
                    Visible = false;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies a bin code for specific location of the task.';
                    Visible = false;
                }
                field("WIP-Total"; Rec."WIP-Total")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the Contrato tasks you want to group together when calculating Work In Process (WIP) and Recognition.';
                    Visible = false;
                }
                field("WIP Method"; Rec."WIP Method")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the name of the Work in Process calculation method that is associated with a Contrato. The value in this field comes from the WIP method specified on the Contrato card.';
                    Visible = false;
                }
                field("Start Date"; Rec."Start Date")
                {
                    ApplicationArea = Basic, Suite, Contratos;
                    ToolTip = 'Specifies the start date for the Contrato task. The date is based on the date on the related Contrato planning line.';
                }
                field("End Date"; Rec."End Date")
                {
                    ApplicationArea = Basic, Suite, Contratos;
                    ToolTip = 'Specifies the end date for the Contrato task. The date is based on the date on the related Contrato planning line.';
                }
                field("Schedule (Total Cost)"; Rec."Schedule (Total Cost)")
                {
                    ApplicationArea = Basic, Suite, Contratos;
                    Caption = 'Budget (Total Cost)';
                    ToolTip = 'Specifies, in the local currency, the total budgeted cost for the Contrato task during the time period in the Planning Date Filter field.';
                }
                field("Schedule (Total Price)"; Rec."Schedule (Total Price)")
                {
                    ApplicationArea = Suite;
                    Caption = 'Budget (Total Price)';
                    ToolTip = 'Specifies, in local currency, the total budgeted price for the Contrato task during the time period in the Planning Date Filter field.';
                    Visible = false;
                }
                field("Usage (Total Cost)"; Rec."Usage (Total Cost)")
                {
                    ApplicationArea = Basic, Suite, Contratos;
                    ToolTip = 'Specifies, in local currency, the total cost of the usage of items, resources and general ledger expenses posted on the Contrato task during the time period in the Posting Date Filter field.';
                }
                field("Usage (Total Price)"; Rec."Usage (Total Price)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies, in the local currency, the total price of the usage of items, resources and general ledger expenses posted on the Contrato task during the time period in the Posting Date Filter field.';
                    Visible = false;
                }
                field("Contract (Total Cost)"; Rec."Contract (Total Cost)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies, in local currency, the total billable cost for the Contrato task during the time period in the Planning Date Filter field.';
                    Visible = false;
                }
                field("Contract (Total Price)"; Rec."Contract (Total Price)")
                {
                    ApplicationArea = Basic, Suite, Contratos;
                    ToolTip = 'Specifies, in the local currency, the total billable price for the Contrato task during the time period in the Planning Date Filter field.';
                }
                field("Contract (Invoiced Cost)"; Rec."Contract (Invoiced Cost)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies, in the local currency, the total billable cost for the Contrato task that has been invoiced during the time period in the Posting Date Filter field.';
                    Visible = false;
                }
                field("Contract (Invoiced Price)"; Rec."Contract (Invoiced Price)")
                {
                    ApplicationArea = Basic, Suite, Contratos;
                    ToolTip = 'Specifies, in the local currency, the total billable price for the Contrato task that has been invoiced during the time period in the Posting Date Filter field.';
                }
                field("Remaining (Total Cost)"; Rec."Remaining (Total Cost)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the remaining total cost (LCY) as the sum of costs from Contrato planning lines associated with the Contrato task. The calculation occurs when you have specified that there is a usage link between the Contrato ledger and the Contrato planning lines.';
                    Visible = false;
                }
                field("Remaining (Total Price)"; Rec."Remaining (Total Price)")
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies the remaining total price (LCY) as the sum of prices from Contrato planning lines associated with the Contrato task. The calculation occurs when you have specified that there is a usage link between the Contrato ledger and the Contrato planning lines.';
                    Visible = false;
                }
                field("EAC (Total Cost)"; Rec.CalcEACTotalCost())
                {
                    ApplicationArea = Suite;
                    Caption = 'EAC (Total Cost)';
                    ToolTip = 'Specifies the estimate at completion (EAC) total cost for a Contrato task line. If the Apply Usage Link check box on the Contrato is selected, then the EAC (Total Cost) field is calculated as follows: Usage (Total Cost) + Remaining (Total Cost).';
                    Visible = false;
                }
                field("EAC (Total Price)"; Rec.CalcEACTotalPrice())
                {
                    ApplicationArea = Suite;
                    Caption = 'EAC (Total Price)';
                    ToolTip = 'Specifies the estimate at completion (EAC) total price for a Contrato task line. If the Apply Usage Link check box on the Contrato is selected, then the EAC (Total Price) field is calculated as follows: Usage (Total Price) + Remaining (Total Price).';
                    Visible = false;
                }
                field("Global Dimension 1 Code"; Rec."Global Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for the global dimension that is linked to the record or entry for analysis purposes. Two global dimensions, typically for the company''s most important activities, are available on all cards, documents, reports, and lists.';
                    Visible = false;
                }
                field("Global Dimension 2 Code"; Rec."Global Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for the global dimension that is linked to the record or entry for analysis purposes. Two global dimensions, typically for the company''s most important activities, are available on all cards, documents, reports, and lists.';
                    Visible = false;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Contratos;
                    Visible = PerTaskBillingFieldsVisible;
                    Editable = PerTaskBillingFieldsVisible;
                    Tooltip = 'Specifies a document number that refers to the customer''s or vendor''s numbering system.';
                }
                field("Your Reference"; Rec."Your Reference")
                {
                    ApplicationArea = Contratos;
                    Visible = PerTaskBillingFieldsVisible;
                    Editable = PerTaskBillingFieldsVisible;
                    Tooltip = 'Specifies the customer''s reference. The content will be printed on sales documents.';
                }
                field("Outstanding Orders"; Rec."Outstanding Orders")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    ToolTip = 'Specifies the sum of outstanding orders, in local currency, for this Contrato task. The value of the Outstanding Amount (LCY) field is used for entries in the Purchase Line table of document type Order to calculate and update the contents of this field.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        PurchLine: Record "Purchase Line";
                        IsHandled: Boolean;
                    begin
                        IsHandled := false;
                        //OnBeforeOnDrillDownOutstandingOrders(Rec, IsHandled);
                        if IsHandled then
                            exit;

                        Rec.ApplyPurchaseLineFilters(PurchLine, Rec."Contrato No.", Rec."Contrato Task No.");
                        PurchLine.SetFilter("Outstanding Amount (LCY)", '<> 0');
                        PAGE.RunModal(PAGE::"Purchase Lines", PurchLine);
                    end;
                }
                field("Amt. Rcd. Not Invoiced"; Rec."Amt. Rcd. Not Invoiced")
                {
                    ApplicationArea = Suite;
                    Editable = false;
                    ToolTip = 'Specifies the sum for items that have been received but have not yet been invoiced. The value in the Amt. Rcd. Not Invoiced (LCY) field is used for entries in the Purchase Line table of document type Order to calculate and update the contents of this field.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        PurchLine: Record "Purchase Line";
                        IsHandled: Boolean;
                    begin
                        IsHandled := false;
                        //OnBeforeOnDrillDownAmtRcdNotInvoiced(Rec, IsHandled);
                        if IsHandled then
                            exit;

                        Rec.ApplyPurchaseLineFilters(PurchLine, Rec."Contrato No.", Rec."Contrato Task No.");
                        PurchLine.SetFilter("Amt. Rcd. Not Invoiced (LCY)", '<> 0');
                        PAGE.RunModal(PAGE::"Purchase Lines", PurchLine);
                    end;
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            group(Line)
            {
                Caption = 'Line';
                group("&Contrato")
                {
                    Caption = '&Contrato';
                    Image = Job;
                    action(ContratoPlanningLines)
                    {
                        ApplicationArea = Contratos;
                        Caption = 'Contrato &Planning Lines';
                        Image = JobLines;
                        Scope = Repeater;
                        ToolTip = 'View all planning lines for the Contrato. You use this window to plan what items, resources, and general ledger expenses that you expect to use on a Contrato (budget) or you can specify what you actually agreed with your customer that he should pay for the Contrato (billable).';

                        trigger OnAction()
                        var
                            ContratoPlanningLine: Record "Contrato Planning Line";
                            ContratoPlanningLines: Page "Contrato Planning Lines";
                            IsHandled: Boolean;
                        begin
                            IsHandled := false;
                            //OnBeforeOnActionContratoPlanningLines(Rec, IsHandled);
                            if IsHandled then
                                exit;
                            Rec.TestField("Contrato No.");
                            ContratoPlanningLine.FilterGroup(2);
                            ContratoPlanningLine.SetRange("Contrato No.", Rec."Contrato No.");
                            ContratoPlanningLine.SetRange("Contrato Task No.", Rec."Contrato Task No.");
                            ContratoPlanningLine.FilterGroup(0);
                            ContratoPlanningLines.SetTableView(ContratoPlanningLine);
                            ContratoPlanningLines.Editable := true;
                            ContratoPlanningLines.Run();
                        end;
                    }
                }
                group("&Dimensions")
                {
                    Caption = '&Dimensions';
                    Image = Dimensions;
                    ShowAs = SplitButton;

                    action("Dimensions-&Single")
                    {
                        ApplicationArea = Dimensions;
                        Caption = 'Dimensions-&Single';
                        Image = Dimensions;
                        RunObject = Page "Contrato Task Dimensions";
                        RunPageLink = "Contrato No." = field("Contrato No."),
                                      "Contrato Task No." = field("Contrato Task No.");
                        ShortCutKey = 'Alt+D';
                        ToolTip = 'View or edit the single set of dimensions that are set up for the selected record.';
                    }
                    action("Dimensions-&Multiple")
                    {
                        AccessByPermission = TableData Dimension = R;
                        ApplicationArea = Dimensions;
                        Caption = 'Dimensions-&Multiple';
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
                group(Documents)
                {
                    Caption = 'Documents';
                    Image = Invoice;
                    action("Create &Sales Invoice")
                    {
                        ApplicationArea = Contratos;
                        Caption = 'Create &Sales Invoice';
                        Ellipsis = true;
                        Image = JobSalesInvoice;
                        ToolTip = 'Use a batch Contrato to help you create sales invoices for the involved Contrato tasks.';

                        trigger OnAction()
                        var
                            Contrato: Record Contrato;
                            ContratoTask: Record "Contrato Task";
                        begin
                            Rec.TestField("Contrato No.");
                            Contrato.Get(Rec."Contrato No.");
                            // if Contrato.Blocked = Contrato.Blocked::All then
                            //     Contrato.TestBlocked();

                            ContratoTask.SetRange("Contrato No.", Contrato."No.");
                            if Rec."Contrato Task No." <> '' then
                                ContratoTask.SetRange("Contrato Task No.", Rec."Contrato Task No.");

                            REPORT.RunModal(REPORT::"Contrato Create Sales Invoice", true, false, ContratoTask);
                        end;
                    }
                    action(SalesInvoicesCreditMemos)
                    {
                        ApplicationArea = Contratos;
                        Caption = 'Sales &Invoices/Credit Memos';
                        Image = GetSourceDoc;
                        ToolTip = 'View sales invoices or sales credit memos that are related to the selected Contrato task.';

                        trigger OnAction()
                        var
                            ContratoInvoices: Page "Contrato Invoices";
                        begin
                            //ContratoInvoices.SetPrContratoTask(Rec);
                            ContratoInvoices.RunModal();
                        end;
                    }
                }
                group(History)
                {
                    Caption = 'History';
                    Image = History;
                    action("Contrato Ledger E&ntries")
                    {
                        ApplicationArea = Contratos;
                        Caption = 'Contrato Ledger E&ntries';
                        Image = JobLedger;
                        RunObject = Page "Contrato Ledger Entries";
                        RunPageLink = "Contrato No." = field("Contrato No."),
                                      "Contrato Task No." = field("Contrato Task No.");
                        RunPageView = sorting("Contrato No.", "Contrato Task No.");
                        ShortCutKey = 'Ctrl+F7';
                        ToolTip = 'View the Contrato ledger entries.';
                    }
                }
                group("F&unctions")
                {
                    Caption = 'F&unctions';
                    Image = "Action";
                    action("Split &Planning Lines")
                    {
                        ApplicationArea = Contratos;
                        Caption = 'Split &Planning Lines';
                        Ellipsis = true;
                        Image = Splitlines;
                        ToolTip = 'Split planning lines of type Budget and Billable into two separate planning lines: Budget and Billable.';

                        trigger OnAction()
                        var
                            Contrato: Record Contrato;
                            ContratoTask: Record "Contrato Task";
                        begin
                            Rec.TestField("Contrato No.");
                            Contrato.Get(Rec."Contrato No.");
                            // if Contrato.Blocked = Contrato.Blocked::All then
                            //     Contrato.TestBlocked();

                            Rec.TestField("Contrato Task No.");
                            ContratoTask.SetRange("Contrato No.", Contrato."No.");
                            ContratoTask.SetRange("Contrato Task No.", Rec."Contrato Task No.");

                            REPORT.RunModal(REPORT::"Contrato Split Planning Line", true, false, ContratoTask);
                        end;
                    }
                    action("Change &Dates")
                    {
                        ApplicationArea = Contratos;
                        Caption = 'Change &Dates';
                        Ellipsis = true;
                        Image = ChangeDate;
                        ToolTip = 'Use a batch Contrato to help you move planning lines on a Contrato from one date interval to another.';

                        trigger OnAction()
                        var
                            Contrato: Record Contrato;
                            ContratoTask: Record "Contrato Task";
                        begin
                            Rec.TestField("Contrato No.");
                            Contrato.Get(Rec."Contrato No.");
                            if Contrato.Blocked = Contrato.Blocked::All then
                                Contrato.TestBlocked();

                            ContratoTask.SetRange("Contrato No.", Contrato."No.");
                            if Rec."Contrato Task No." <> '' then
                                ContratoTask.SetRange("Contrato Task No.", Rec."Contrato Task No.");

                            REPORT.RunModal(REPORT::"Change Contrato Dates", true, false, ContratoTask);
                        end;
                    }
                    action("<Action7>")
                    {
                        ApplicationArea = Contratos;
                        Caption = 'I&ndent Contrato Tasks';
                        Image = Indent;
                        RunObject = Codeunit "Job Task-Indent";
                        ToolTip = 'Move the selected lines in one position to show that the tasks are subcategories of other tasks. Contrato tasks that are totaled are the ones that lie between one pair of corresponding Begin-Total and End-Total Contrato tasks.';
                    }
                    group("&Copy")
                    {
                        Caption = '&Copy';
                        Image = Copy;
                        action("Copy Contrato Planning Lines &from...")
                        {
                            ApplicationArea = Contratos;
                            Caption = 'Copy Contrato Planning Lines &from...';
                            Ellipsis = true;
                            Image = CopyToTask;
                            ToolTip = 'Use a batch Contrato to help you copy planning lines from one Contrato task to another. You can copy from a Contrato task within the Contrato you are working with or from a Contrato task linked to a different Contrato.';

                            trigger OnAction()
                            var
                                CopyContratoPlanningLines: Page "Copy Contrato Planning Lines";
                            begin
                                Rec.TestField("Contrato Task Type", Rec."Contrato Task Type"::Posting);
                                //CopyContratoPlanningLines.SetToContratoTask(Rec);
                                CopyContratoPlanningLines.RunModal();
                            end;
                        }
                        action("Copy Contrato Planning Lines &to...")
                        {
                            ApplicationArea = Contratos;
                            Caption = 'Copy Contrato Planning Lines &to...';
                            Ellipsis = true;
                            Image = CopyFromTask;
                            ToolTip = 'Use a batch Contrato to help you copy planning lines from one Contrato task to another. You can copy from a Contrato task within the Contrato you are working with or from a Contrato task linked to a different Contrato.';

                            trigger OnAction()
                            var
                                CopyContratoPlanningLines: Page "Copy Contrato Planning Lines";
                            begin
                                Rec.TestField("Contrato Task Type", "Contrato Task Type"::Posting);
                                //CopyContratoPlanningLines.SetFromContratoTask(Rec);
                                CopyContratoPlanningLines.RunModal();
                            end;
                        }
                    }
                    group("<Action13>")
                    {
                        Caption = 'W&IP';
                        Image = WIP;
                        action("<Action48>")
                        {
                            ApplicationArea = Contratos;
                            Caption = '&Calculate WIP';
                            Ellipsis = true;
                            Image = CalculateWIP;
                            ToolTip = 'Run the Contrato Calculate WIP batch Contrato.';

                            trigger OnAction()
                            var
                                Contrato: Record Contrato;
                            begin
                                Rec.TestField("Contrato No.");
                                Contrato.Get(Rec."Contrato No.");
                                Contrato.SetRange("No.", Contrato."No.");
                                REPORT.RunModal(REPORT::"Contrato Calculate WIP", true, false, Contrato);
                            end;
                        }
                        action("<Action49>")
                        {
                            ApplicationArea = Contratos;
                            Caption = '&Post WIP to G/L';
                            Ellipsis = true;
                            Image = PostOrder;
                            ShortCutKey = 'F9';
                            ToolTip = 'Run the Contrato Post WIP to G/L batch Contrato.';

                            trigger OnAction()
                            var
                                Contrato: Record Contrato;
                            begin
                                Rec.TestField("Contrato No.");
                                Contrato.Get(Rec."Contrato No.");
                                Contrato.SetRange("No.", Contrato."No.");
                                REPORT.RunModal(REPORT::"Contrato Post WIP to G/L", true, false, Contrato);
                            end;
                        }
                    }
                }
            }
        }
    }

    trigger OnAfterGetRecord()
    begin
        DescriptionIndent := Rec.Indentation;
        StyleIsStrong := Rec."Contrato Task Type" <> "Contrato Task Type"::Posting;
        PostingTypeRow := Rec."Contrato Task Type" = "Contrato Task Type"::Posting;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.ClearTempDim();
        StyleIsStrong := Rec."Contrato Task Type" <> "Contrato Task Type"::Posting;
        PostingTypeRow := Rec."Contrato Task Type" = "Contrato Task Type"::Posting;
    end;

    var
        DescriptionIndent: Integer;
        StyleIsStrong: Boolean;
        PerTaskBillingFieldsVisible: Boolean;
        PostingTypeRow: Boolean;
#if not CLEAN24
        RefreshCustomerControl: Boolean;
#endif

    procedure SetPerTaskBillingFieldsVisible(Visible: Boolean)
    begin
        PerTaskBillingFieldsVisible := Visible;
        CurrPage.Update(false);
    end;

#if not CLEAN24
    procedure SetRefreshCustomerControl(Refresh: Boolean)
    begin
        RefreshCustomerControl := Refresh;
    end;
#endif

    [IntegrationEvent(true, false)]
    local procedure OnBeforeOnActionContratoPlanningLines(var ContratoTask: Record "Contrato Task"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeOnDrillDownOutstandingOrders(var ContratoTask: Record "Contrato Task"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeOnDrillDownAmtRcdNotInvoiced(var ContratoTask: Record "Contrato Task"; var IsHandled: Boolean);
    begin
    end;
}

