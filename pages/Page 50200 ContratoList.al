
page 50200 "Contrato List"
{
    AdditionalSearchTerms = 'Contratos, Contratos Arsesa';
    ApplicationArea = All;
    Caption = 'Contratos';
    CardPageID = "Contrato Card";
    Editable = false;
    PageType = List;
    QueryCategory = 'Contrato';
    SourceTable = Contrato;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a short description of the contrato.';
                }
                field("Bill-to Customer No."; Rec."Bill-to Customer No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the customer who pays for the project.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a status for the current project. You can change the status for the project as it progresses. Final calculations can be made on completed projects.';
                }
                field("Person Responsible"; Rec."Person Responsible")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the person responsible for the project. You can select a name from the list of resources available in the Resource List window. The name is copied from the No. field in the Resource table. You can choose the field to see a list of resources.';
                    Visible = false;
                }
                // field("Next Invoice Date"; Rec."Next Invoice Date")
                // {
                //     ApplicationArea = All;
                //     ToolTip = 'Specifies the next invoice date for the project.';
                //     Visible = false;
                // }
                field("Contrato Posting Group"; Rec."Contrato Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a project posting group code for a project. To see the available codes, choose the field.';
                    Visible = false;
                }
                field("Search Description"; Rec."Search Description")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the additional name for the project. The field is used for searching purposes.';
                }
                field("% of Overdue Planning Lines"; Rec.PercentOverdue())
                {
                    ApplicationArea = All;
                    Caption = '% of Overdue Planning Lines';
                    Editable = false;
                    ToolTip = 'Specifies the percent of planning lines that are overdue for this project.';
                    Visible = false;
                }
                field("% Completed"; Rec.PercentCompleted())
                {
                    ApplicationArea = All;
                    Caption = '% Completed';
                    Editable = false;
                    ToolTip = 'Specifies the completion percentage for this project.';
                    Visible = false;
                }
                field("% Invoiced"; Rec.PercentInvoiced())
                {
                    ApplicationArea = All;
                    Caption = '% Invoiced';
                    Editable = false;
                    ToolTip = 'Specifies the invoiced percentage for this project.';
                    Visible = false;
                }
                field("Project Manager"; Rec."Project Manager")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the person assigned as the manager for this project.';
                    Visible = false;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a document number that refers to the customer''s or vendor''s numbering system.';
                    Visible = false;
                }
                field("Your Reference"; Rec."Your Reference")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the customer''s reference. The content will be printed on sales documents.';
                    Visible = false;
                }
            }
        }
        area(factboxes)
        {
            part(PowerBIEmbeddedReportPart; "Power BI Embedded Report Part")
            {
                ApplicationArea = Basic, Suite;
                Visible = false;
            }
            part(Control1907234507; "Sales Hist. Bill-to FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("Bill-to Customer No.");
                Visible = false;
            }
            part(Control1902018507; "Customer Statistics FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("Bill-to Customer No.");
                Visible = false;
            }
            part(Control1905650007; "Contr WIP/Recognition FactBox")
            {
                ApplicationArea = All;
                SubPageLink = "No." = field("No.");
            }
            part("Contrato Details"; "Contrato Cost Factbox")
            {
                ApplicationArea = All;
                Caption = 'Contrato Details';
                SubPageLink = "No." = field("No.");
            }
            part("Attached Documents"; "Document Attachment Factbox")
            {
                ApplicationArea = All;
                Caption = 'Attachments';
                SubPageLink = "Table ID" = const(Database::Contrato),
                              "No." = field("No.");
            }
            systempart(Control1900383207; Links)
            {
                ApplicationArea = RecordLinks;
                Visible = false;
            }
            systempart(Control1905767507; Notes)
            {
                ApplicationArea = Notes;
            }
        }
    }

    actions
    {
        area(navigation)
        {
            group("&Contrato")
            {
                Caption = '&Contrato';
                Image = Signature;
                action("Contrato Task &Lines")
                {
                    ApplicationArea = All;
                    Caption = 'Contrato Task &Lines';
                    Image = TaskList;
                    RunObject = Page "Contrato Task Lines";
                    RunPageLink = "Job No." = field("No.");
                    ToolTip = 'Plan how you want to set up your planning information. In this window you can specify the tasks involved in a project. To start planning a project or to post usage for a project, you must set up at least one project task.';
                }
                group("&Dimensions")
                {
                    Caption = '&Dimensions';
                    Image = Dimensions;
                    action("Dimensions-&Single")
                    {
                        ApplicationArea = Dimensions;
                        Caption = 'Dimensions-&Single';
                        Image = Dimensions;
                        RunObject = Page "Default Dimensions";
                        RunPageLink = "Table ID" = const(167),
                                      "No." = field("No.");
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
                            Contrato: Record Contrato;
                            DefaultDimensionsMultiple: Page "Default Dimensions-Multiple";
                        begin
                            CurrPage.SetSelectionFilter(Contrato);
                            DefaultDimensionsMultiple.SetMultiRecord(Contrato, Rec.FieldNo("No."));
                            DefaultDimensionsMultiple.RunModal();
                        end;
                    }
                }
                action("&Statistics")
                {
                    ApplicationArea = All;
                    Caption = '&Statistics';
                    Image = Statistics;
                    RunObject = Page "Job Statistics";
                    RunPageLink = "No." = field("No.");
                    ShortCutKey = 'F7';
                    ToolTip = 'View this project''s statistics.';
                }
                action(SalesInvoicesCreditMemos)
                {
                    ApplicationArea = All;
                    Caption = 'Sales &Invoices/Credit Memos';
                    Image = GetSourceDoc;
                    ToolTip = 'View sales invoices or sales credit memos that are related to the selected project.';

                    trigger OnAction()
                    var
                        JobInvoices: Page "Contrato Invoices";
                    begin
                        JobInvoices.SetPrJob(Rec);
                        JobInvoices.RunModal();
                    end;
                }
                action("Co&mments")
                {
                    ApplicationArea = Comments;
                    Caption = 'Co&mments';
                    Image = ViewComments;
                    RunObject = Page "Comment Sheet";
                    RunPageLink = "Table Name" = const(Job),
                                  "No." = field("No.");
                    ToolTip = 'View or add comments for the record.';
                }
            }
            group("W&IP")
            {
                Caption = 'W&IP';
                Image = WIP;
                action("&WIP Entries")
                {
                    ApplicationArea = All;
                    Caption = '&WIP Entries';
                    Image = WIPEntries;
                    RunObject = Page "Contrato WIP Entries";
                    RunPageLink = "Job No." = field("No.");
                    RunPageView = sorting("Job No.", "Contrato Posting Group", "WIP Posting Date")
                                  order(descending);
                    ToolTip = 'View entries for the project that are posted as work in process.';
                }
                action("WIP &G/L Entries")
                {
                    ApplicationArea = All;
                    Caption = 'WIP &G/L Entries';
                    Image = WIPLedger;
                    RunObject = Page "Job WIP G/L Entries";
                    RunPageLink = "Job No." = field("No.");
                    RunPageView = sorting("Job No.")
                                  order(descending);
                    ToolTip = 'View the project''s WIP G/L entries.';
                }
            }
#if not CLEAN23
            group("&Prices")
            {
                Caption = '&Prices';
                Image = Price;
                Visible = not ExtendedPriceEnabled;
                ObsoleteState = Pending;
                ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
                ObsoleteTag = '17.0';
                action("&Resource")
                {
                    ApplicationArea = All;
                    Caption = '&Resource';
                    Image = Resource;
                    Visible = not ExtendedPriceEnabled;
                    RunObject = Page "Job Resource Prices";
                    RunPageLink = "Job No." = field("No.");
                    ToolTip = 'View this project''s resource prices.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
                    ObsoleteTag = '17.0';
                }
                action("&Item")
                {
                    ApplicationArea = All;
                    Caption = '&Item';
                    Image = Item;
                    Visible = not ExtendedPriceEnabled;
                    RunObject = Page "Job Item Prices";
                    RunPageLink = "Job No." = field("No.");
                    ToolTip = 'View this project''s item prices.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
                    ObsoleteTag = '17.0';
                }
                action("&G/L Account")
                {
                    ApplicationArea = All;
                    Caption = '&G/L Account';
                    Image = JobPrice;
                    Visible = not ExtendedPriceEnabled;
                    RunObject = Page "Job G/L Account Prices";
                    RunPageLink = "Job No." = field("No.");
                    ToolTip = 'View this project''s G/L account prices.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
                    ObsoleteTag = '17.0';
                }
            }
#endif
            group(Prices)
            {
                Caption = '&Prices';
                Image = Price;
                Visible = ExtendedPriceEnabled;
                action(SalesPriceLists)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Price Lists';
                    Image = Price;
                    Visible = ExtendedPriceEnabled;
                    ToolTip = 'View or set up sales price lists for products that you sell to the customer. A product price is automatically granted on invoice lines when the specified criteria are met, such as customer, quantity, or ending date.';

                    trigger OnAction()
                    var
                        PriceUXManagement: Codeunit "Price UX Management";
                    begin
                        //PriceUXManagement.ShowPriceLists(Rec, Enum::"Price Type"::Sale, Enum::"Price Amount Type"::Any);
                    end;
                }
                action(SalesPriceLines)
                {
                    AccessByPermission = TableData "Sales Price Access" = R;
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Prices';
                    Image = Price;
                    Scope = Repeater;
                    Visible = ExtendedPriceEnabled;
                    ToolTip = 'View or set up sales price lines for products that you sell to the customer. A product price is automatically granted on invoice lines when the specified criteria are met, such as customer, quantity, or ending date.';

                    trigger OnAction()
                    var
                        PriceSource: Record "Price Source";
                        PriceUXManagement: Codeunit "Price UX Management";
                    begin
                        Rec.ToPriceSource(PriceSource, Enum::"Price Type"::Sale);
                        PriceUXManagement.ShowPriceListLines(PriceSource, Enum::"Price Amount Type"::Price);
                    end;
                }
                action(SalesDiscountLines)
                {
                    AccessByPermission = TableData "Sales Discount Access" = R;
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Discounts';
                    Image = LineDiscount;
                    Scope = Repeater;
                    Visible = ExtendedPriceEnabled;
                    ToolTip = 'View or set up different discounts for products that you sell to the customer. A product line discount is automatically granted on invoice lines when the specified criteria are met, such as customer, quantity, or ending date.';

                    trigger OnAction()
                    var
                        PriceSource: Record "Price Source";
                        PriceUXManagement: Codeunit "Price UX Management";
                    begin
                        Rec.ToPriceSource(PriceSource, Enum::"Price Type"::Sale);
                        PriceUXManagement.ShowPriceListLines(PriceSource, Enum::"Price Amount Type"::Discount);
                    end;
                }
#if not CLEAN23
                action(SalesPriceListsDiscounts)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Sales Price Lists (Discounts)';
                    Image = LineDiscount;
                    Visible = false;
                    ToolTip = 'View or set up different discounts for products that you sell to the customer. A product line discount is automatically granted on invoice lines when the specified criteria are met, such as customer, quantity, or ending date.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Action SalesPriceLists shows all sales price lists with prices and discounts';
                    ObsoleteTag = '18.0';

                    trigger OnAction()
                    var
                        PriceUXManagement: Codeunit "Price UX Management";
                        AmountType: Enum "Price Amount Type";
                        PriceType: Enum "Price Type";
                    begin
                        //PriceUXManagement.ShowPriceLists(Rec, PriceType::Sale, AmountType::Discount);
                    end;
                }
#endif
                action(PurchasePriceLists)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchase Price Lists';
                    Image = ResourceCosts;
                    Visible = ExtendedPriceEnabled;
                    ToolTip = 'View or set up purchase price lists for products that you buy from the vendor. An product price is automatically granted on invoice lines when the specified criteria are met, such as vendor, quantity, or ending date.';

                    trigger OnAction()
                    var
                        PriceUXManagement: Codeunit "Price UX Management";
                    begin
                        //PriceUXManagement.ShowPriceLists(Rec, Enum::"Price Type"::Purchase, Enum::"Price Amount Type"::Any);
                    end;
                }
                action(PurchPriceLines)
                {
                    AccessByPermission = TableData "Purchase Price Access" = R;
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchase Prices';
                    Image = Price;
                    Scope = Repeater;
                    Visible = ExtendedPriceEnabled;
                    ToolTip = 'View or set up purchase price lines for products that you buy from the vendor. A product price is automatically granted on invoice lines when the specified criteria are met, such as vendor, quantity, or ending date.';

                    trigger OnAction()
                    var
                        PriceSource: Record "Price Source";
                        PriceUXManagement: Codeunit "Price UX Management";
                    begin
                        Rec.ToPriceSource(PriceSource, Enum::"Price Type"::Purchase);
                        PriceUXManagement.ShowPriceListLines(PriceSource, Enum::"Price Amount Type"::Price);
                    end;
                }
                action(PurchDiscountLines)
                {
                    AccessByPermission = TableData "Purchase Discount Access" = R;
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchase Discounts';
                    Image = LineDiscount;
                    Scope = Repeater;
                    Visible = ExtendedPriceEnabled;
                    ToolTip = 'View or set up different discounts for products that you buy from the vendor. A product line discount is automatically granted on invoice lines when the specified criteria are met, such as vendor, quantity, or ending date.';

                    trigger OnAction()
                    var
                        PriceSource: Record "Price Source";
                        PriceUXManagement: Codeunit "Price UX Management";
                    begin
                        Rec.ToPriceSource(PriceSource, Enum::"Price Type"::Purchase);
                        PriceUXManagement.ShowPriceListLines(PriceSource, Enum::"Price Amount Type"::Discount);
                    end;
                }
#if not CLEAN23
                action(PurchasePriceListsDiscounts)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Purchase Price Lists (Discounts)';
                    Image = LineDiscount;
                    Visible = false;
                    ToolTip = 'View or set up different discounts for products that you buy from the vendor. An product discount is automatically granted on invoice lines when the specified criteria are met, such as vendor, quantity, or ending date.';
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Action PurchasePriceLists shows all purchase price lists with prices and discounts';
                    ObsoleteTag = '18.0';

                    trigger OnAction()
                    var
                        PriceUXManagement: Codeunit "Price UX Management";
                        AmountType: Enum "Price Amount Type";
                        PriceType: Enum "Price Type";
                    begin
                        //PriceUXManagement.ShowPriceLists(Rec, PriceType::Purchase, AmountType::Discount);
                    end;
                }
#endif
            }
            group("Plan&ning")
            {
                Caption = 'Plan&ning';
                Image = Planning;
                action("Resource &Allocated per Contrato")
                {
                    ApplicationArea = All;
                    Caption = 'Resource &Allocated per Contrato';
                    Image = ViewJob;
                    RunObject = Page "Resource Allocated per Job";
                    ToolTip = 'View this project''s resource allocation.';
                }
                action("Res. Group All&ocated per Contrato")
                {
                    ApplicationArea = All;
                    Caption = 'Res. Group All&ocated per Contrato';
                    Image = ViewJob;
                    RunObject = Page "Res. Gr. Allocated per Job";
                    ToolTip = 'View the project''s resource group allocation.';
                }
            }
            group(History)
            {
                Caption = 'History';
                Image = History;
                action("Ledger E&ntries")
                {
                    ApplicationArea = All;
                    Caption = 'Ledger E&ntries';
                    Image = CustomerLedger;
                    RunObject = Page "Contrato Ledger Entries";
                    RunPageLink = "Job No." = field("No.");
                    RunPageView = sorting("Job No.", "Job Task No.", "Entry Type", "Posting Date")
                                  order(descending);
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View the history of transactions that have been posted for the selected record.';
                }
            }
        }
        area(processing)
        {
            group("<Action9>")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(CopyJob)
                {
                    ApplicationArea = All;
                    Caption = '&Copy Contrato';
                    Ellipsis = true;
                    Image = CopyFromTask;
                    ToolTip = 'Copy a project and its project tasks, planning lines, and prices.';

                    trigger OnAction()
                    var
                        CopyJob: Page "Copy Job";
                    begin
                        //CopyJob.SetFromJob(Rec);
                        CopyJob.RunModal();
                    end;
                }
                action("Create Contrato &Sales Invoice")
                {
                    ApplicationArea = All;
                    Caption = 'Create Contrato &Sales Invoice';
                    Image = JobSalesInvoice;
                    RunObject = Report "Job Create Sales Invoice";
                    ToolTip = 'Use a batch job to help you create project sales invoices for the involved project planning lines.';
                }

                group(Action7)
                {
                    Caption = 'W&IP';
                    Image = WIP;
                    action("<Action151>")
                    {
                        ApplicationArea = All;
                        Caption = '&Calculate WIP';
                        Ellipsis = true;
                        Image = CalculateWIP;
                        //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                        //PromotedCategory = Process;
                        ToolTip = 'Run the Contrato Calculate WIP batch job.';

                        trigger OnAction()
                        var
                            Contrato: Record Contrato;
                            JobCalculateWIP: Report "Job Calculate WIP";
                        begin
                            Rec.TestField("No.");
                            Contrato.Copy(Rec);
                            Contrato.SetRange("No.", Rec."No.");
                            JobCalculateWIP.SetTableView(Contrato);
                            JobCalculateWIP.Run();
                        end;
                    }
                    action("<Action152>")
                    {
                        ApplicationArea = All;
                        Caption = '&Post WIP to G/L';
                        Ellipsis = true;
                        Image = PostOrder;
                        //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                        //PromotedCategory = Process;
                        ToolTip = 'Run the Contrato Post WIP to G/L batch job.';

                        trigger OnAction()
                        var
                            Contrato: Record Contrato;
                        begin
                            Rec.TestField("No.");
                            Contrato.Copy(Rec);
                            Contrato.SetRange("No.", Rec."No.");
                            REPORT.RunModal(REPORT::"Job Post WIP to G/L", true, false, Contrato);
                        end;
                    }
                }
            }
        }
        area(reporting)
        {
            action("Contrato Actual to Budget")
            {
                ApplicationArea = All;
                Caption = 'Contrato Actual to Budget';
                Image = "Report";
                RunObject = Report "Job Actual To Budget";
                ToolTip = 'Compare budgeted and usage amounts for selected projects. All lines of the selected project show quantity, total cost, and line amount.';
                Visible = false;
            }
            action("Contrato Actual to Budget (Cost)")
            {
                ApplicationArea = All;
                Caption = 'Contrato Actual to Budget (Cost)';
                Image = "Report";
                RunObject = Report "Job Actual to Budget (Cost)";
                ToolTip = 'Compare budgeted and usage amounts for selected projects. All lines of the selected project show quantity, total cost, and line amount.';
            }
            action("Contrato Actual to Budget (Price)")
            {
                ApplicationArea = All;
                Caption = 'Contrato Actual to Budget (Price)';
                Image = "Report";
                RunObject = Report "Job Actual to Budget (Price)";
                ToolTip = 'Compare the actual price of your jobs to the price that was budgeted. The report shows budget and actual amounts for each phase, task, and steps.';
            }
            action("Contrato Analysis")
            {
                ApplicationArea = All;
                Caption = 'Contrato Analysis';
                Image = "Report";
                RunObject = Report "Job Analysis";
                ToolTip = 'Analyze the project, such as the budgeted prices, usage prices, and contract prices, and then compares the three sets of prices.';
            }
            action("Contrato - Planning Lines")
            {
                ApplicationArea = All;
                Caption = 'Contrato - Planning Lines';
                Image = "Report";
                RunObject = Report "Job - Planning Lines";
                ToolTip = 'View all planning lines for the project. You use this window to plan what items, resources, and general ledger expenses that you expect to use on a project (budget) or you can specify what you actually agreed with your customer that he should pay for the project (billable).';
            }
            action("Contrato - Suggested Billing")
            {
                ApplicationArea = All;
                Caption = 'Contrato - Suggested Billing';
                Image = "Report";
                RunObject = Report "Job Suggested Billing";
                ToolTip = 'View a list of all projects, grouped by customer, how much the customer has already been invoiced, and how much remains to be invoiced, that is, the suggested billing.';
                Visible = false;
            }
            action("Contrato Cost Suggested Billing")
            {
                ApplicationArea = All;
                Caption = 'Contrato Cost Suggested Billing';
                Image = "Report";
                RunObject = Report "Job Cost Suggested Billing";
                ToolTip = 'View a list of all projects, grouped by customer, how much the customer has already been invoiced, and how much remains to be invoiced, that is, the suggested billing.';
            }
            action("Generar Factura Producto")
            {
                ApplicationArea = All;
                Caption = 'Generar Factura Producto';
                Image = "Report";
                RunObject = Report "Contrato Producto Factura";
                ToolTip = 'View a list of all projects, grouped by customer, how much the customer has already been invoiced, and how much remains to be invoiced, that is, the suggested billing.';
            }
            action("Customer Jobs (Cost)")
            {
                ApplicationArea = All;
                Caption = 'Customer Projects(Cost)';
                Image = "Report";
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Customer Jobs (Cost)";
                ToolTip = 'Run the Projects per Customer report.';
            }
            action("Jobs per Customer")
            {
                ApplicationArea = All;
                Caption = 'Projects per Customer';
                Image = "Report";
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Jobs per Customer";
                ToolTip = 'Run the Projects per Customer report.';
                Visible = false;
            }
            action("Customer Jobs (Price)")
            {
                ApplicationArea = All;
                Caption = 'Customer Projects (Price)';
                Image = "Report";
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Customer Jobs (Price)";
                ToolTip = 'View projects and project prices by customer. The report only includes projects that are marked as completed.';
            }
            action("Items per Contrato")
            {
                ApplicationArea = All;
                Caption = 'Items per Contrato';
                Image = "Report";
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Items per Job";
                ToolTip = 'View which items are used for a specific project.';
            }
            action("Jobs per Item")
            {
                ApplicationArea = All;
                Caption = 'Projects per Item';
                Image = "Report";
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "Jobs per Item";
                ToolTip = 'Run the Projects per item report.';
            }
            action("Report Job Quote")
            {
                ApplicationArea = All;
                Caption = 'Preview Job Quote';
                Image = "Report";
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                ToolTip = 'Open the Job Quote report.';

                trigger OnAction()
                var
                    Contrato: Record Contrato;
                begin
                    //Contrato := Rec;
                    CurrPage.SetSelectionFilter(Contrato);
                    Contrato.PrintRecords(true);
                end;
            }
            action("Send Contrato Quote")
            {
                ApplicationArea = All;
                Caption = 'Send Contrato Quote';
                Image = SendTo;
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                ToolTip = 'Send the project quote to the customer. You can change the way that the document is sent in the window that appears.';

                trigger OnAction()
                begin
                    CODEUNIT.Run(CODEUNIT::"Jobs-Send", Rec);
                end;
            }
            group("Financial Management")
            {
                Caption = 'Financial Management';
                Image = "Report";
                action("Contrato WIP to G/L")
                {
                    ApplicationArea = All;
                    Caption = 'Contrato WIP to G/L';
                    Image = "Report";
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";
                    RunObject = Report "Job WIP To G/L";
                    ToolTip = 'View the value of work in process on the projects that you select compared to the amount that has been posted in the general ledger.';
                }
            }
            group(Action23)
            {
                Caption = 'History';
                Image = "Report";
                action("Jobs - Transaction Detail")
                {
                    ApplicationArea = All;
                    Caption = 'Projects - Transaction Detail';
                    Image = "Report";
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";
                    RunObject = Report "Job - Transaction Detail";
                    ToolTip = 'View all postings with entries for a selected project for a selected period, which have been charged to a certain project. At the end of each project list, the amounts are totaled separately for the Sales and Usage entry types.';
                    Visible = false;
                }
                action("Contrato Cost Transaction Detail")
                {
                    ApplicationArea = All;
                    Caption = 'Projects Cost Transaction Detail';
                    Image = "Report";
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";
                    RunObject = Report "Job Cost Transaction Detail";
                    ToolTip = 'View all postings with entries for a selected project for a selected period, which have been charged to a certain project. At the end of each project list, the amounts are totaled separately for the Sales and Usage entry types.';
                }
                action("Contrato Register")
                {
                    ApplicationArea = All;
                    Caption = 'Contrato Register';
                    Image = "Report";
                    //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                    //PromotedCategory = "Report";
                    RunObject = Report "Job Register";
                    ToolTip = 'View one or more selected project registers. By using a filter, you can select only those register entries that you want to see. If you do not set a filter, the report can be impractical because it can contain a large amount of information. On the project journal template, you can indicate that you want the report to print when you post.';
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 1.';

                actionref(CopyJob_Promoted; CopyJob)
                {
                }
                actionref("Create Contrato &Sales Invoice_Promoted"; "Create Contrato &Sales Invoice")
                {
                }
            }
            group(Category_Category5)
            {
                Caption = 'Contrato', Comment = 'Generated from the PromotedActionCategories property index 4.';

                group(Category_Dimensions)
                {
                    Caption = 'Dimensions';
                    ShowAs = SplitButton;

                    actionref("Dimensions-&Multiple_Promoted"; "Dimensions-&Multiple")
                    {
                    }
                    actionref("Dimensions-&Single_Promoted"; "Dimensions-&Single")
                    {
                    }
                }
                actionref("&Statistics_Promoted"; "&Statistics")
                {
                }
                actionref("Co&mments_Promoted"; "Co&mments")
                {
                }
                actionref(SalesInvoicesCreditMemos_Promoted; SalesInvoicesCreditMemos)
                {
                }
                actionref("Contrato Task &Lines_Promoted"; "Contrato Task &Lines")
                {
                }
                actionref("Ledger E&ntries_Promoted"; "Ledger E&ntries")
                {
                }
            }
            group(Category_Category6)
            {
                Caption = 'Prices & Discounts', Comment = 'Generated from the PromotedActionCategories property index 5.';

#if not CLEAN23
#pragma warning disable AL0432
                actionref("&Resource_Promoted"; "&Resource")
#pragma warning restore AL0432
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
                    ObsoleteTag = '17.0';
                }
#endif
#if not CLEAN23
#pragma warning disable AL0432
                actionref("&Item_Promoted"; "&Item")
#pragma warning restore AL0432
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
                    ObsoleteTag = '17.0';
                }
#endif
#if not CLEAN23
#pragma warning disable AL0432
                actionref("&G/L Account_Promoted"; "&G/L Account")
#pragma warning restore AL0432
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
                    ObsoleteTag = '17.0';
                }
#endif
            }
            group(Category_WIP)
            {
                Caption = 'WIP';

                actionref("<Action151>_Promoted"; "<Action151>")
                {
                }
                actionref("<Action152>_Promoted"; "<Action152>")
                {
                }
                actionref("&WIP Entries_Promoted"; "&WIP Entries")
                {
                }
                actionref("WIP &G/L Entries_Promoted"; "WIP &G/L Entries")
                {
                }
            }
            group(Category_Category4)
            {
                Caption = 'Navigate', Comment = 'Generated from the PromotedActionCategories property index 3.';

                actionref(SalesPriceLines_Promoted; SalesPriceLines)
                {
                }
                actionref(SalesPriceLists_Promoted; SalesPriceLists)
                {
                }
                actionref(PurchPriceLines_Promoted; PurchPriceLines)
                {
                }
                actionref(PurchasePriceLists_Promoted; PurchasePriceLists)
                {
                }
                actionref(SalesDiscountLines_Promoted; SalesDiscountLines)
                {
                }
                actionref(PurchDiscountLines_Promoted; PurchDiscountLines)
                {
                }
#if not CLEAN23
#pragma warning disable AL0432
                actionref(SalesPriceListsDiscounts_Promoted; SalesPriceListsDiscounts)
#pragma warning restore AL0432
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Action SalesPriceLists shows all sales price lists with prices and discounts';
                    ObsoleteTag = '18.0';
                }
#endif
#if not CLEAN23
#pragma warning disable AL0432
                actionref(PurchasePriceListsDiscounts_Promoted; PurchasePriceListsDiscounts)
#pragma warning restore AL0432
                {
                    ObsoleteState = Pending;
                    ObsoleteReason = 'Action PurchasePriceLists shows all purchase price lists with prices and discounts';
                    ObsoleteTag = '18.0';
                }
#endif
            }
            group(Category_Report)
            {
                Caption = 'Report', Comment = 'Generated from the PromotedActionCategories property index 2.';

                actionref("Contrato - Planning Lines_Promoted"; "Contrato - Planning Lines")
                {
                }
                actionref("Contrato Actual to Budget (Cost)_Promoted"; "Contrato Actual to Budget (Cost)")
                {
                }
                actionref("Contrato Actual to Budget (Price)_Promoted"; "Contrato Actual to Budget (Price)")
                {
                }
                actionref("Contrato Analysis_Promoted"; "Contrato Analysis")
                {
                }
                actionref("Contrato Cost Suggested Billing_Promoted"; "Contrato Cost Suggested Billing")
                {
                }
                actionref("Contrato Cost Suggested Billing_2Promoted"; "Generar Factura Producto")
                {
                }
            }
        }
    }

    views
    {
        view(Open)
        {
            Caption = 'Open';
            Filters = where(Status = const(Open));
        }
        view(PlannedAndQuoted)
        {
            Caption = 'Planned and Quoted';
            Filters = where(Status = filter(Quote | Planning));
        }
        view(Completed)
        {
            Caption = 'Completed';
            Filters = where(Status = const(Completed));
        }
    }

    trigger OnAfterGetCurrRecord()
    var
        Contrato: Record Contrato;
    begin
        CurrPage.SetSelectionFilter(Contrato);
        CurrPage.PowerBIEmbeddedReportPart.PAGE.SetFilterToMultipleValues(Contrato, Contrato.FieldNo("No."));
    end;

    trigger OnOpenPage()
    var
        PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
    begin
        ExtendedPriceEnabled := PriceCalculationMgt.IsExtendedPriceCalculationEnabled();
    end;

    trigger OnInit()
    begin
        CurrPage.PowerBIEmbeddedReportPart.PAGE.SetPageContext(CurrPage.ObjectId(false));
    end;

    var
        ExtendedPriceEnabled: Boolean;
}

