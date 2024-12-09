page 50205 "Contrato Journal"
{
    AdditionalSearchTerms = 'Contrato posting, Contrato Journals';
    ApplicationArea = Contratos;
    AutoSplitKey = true;
    Caption = 'Contrato Journals';
    DataCaptionFields = "Journal Batch Name";
    DelayedInsert = true;
    PageType = Worksheet;
    SaveValues = true;
    SourceTable = "Contrato Journal Line";
    UsageCategory = Tasks;

    layout
    {
        area(content)
        {
            field(CurrentJnlBatchName; CurrentJnlBatchName)
            {
                ApplicationArea = Contratos;
                Caption = 'Batch Name';
                Lookup = true;
                ToolTip = 'Specifies the name of the journal batch, a personalized journal layout, that the journal is based on.';

                trigger OnLookup(var Text: Text): Boolean
                begin
                    CurrPage.SaveRecord();
                    ContratoJnlManagement.LookupName(CurrentJnlBatchName, Rec);
                    SetControlAppearanceFromBatch();
                    CurrPage.Update(false);
                end;

                trigger OnValidate()
                begin
                    ContratoJnlManagement.CheckName(CurrentJnlBatchName, Rec);
                    CurrentJnlBatchNameOnAfterVali();
                end;
            }
            repeater(Control1)
            {
                ShowCaption = false;
                field("Line Type"; Rec."Line Type")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the type of planning line to create when a Contrato ledger entry is posted. If the field is empty, no planning lines are created.';
                }
                field("Posting Date"; Rec."Posting Date")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the posting date you want to assign to each journal line. For more information, see Entering Dates and Times.';
                }
                field("Document Date"; Rec."Document Date")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the date when the related document was created.';
                    Visible = false;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies a document number for the journal line.';
                    ShowMandatory = true;
                }
                field("External Document No."; Rec."External Document No.")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies a document number that refers to the customer''s or vendor''s numbering system.';
                    Visible = false;
                }
                field("Contrato No."; Rec."Contrato No.")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the number of the Contrato.';

                    trigger OnValidate()
                    begin
                        ContratoJnlManagement.GetNames(Rec, ContratoDescription, AccName);
                        Rec.ShowShortcutDimCode(ShortcutDimCode);
                    end;
                }
                field("Contrato Task No."; Rec."Contrato Task No.")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the number of the related Contrato task.';

                    trigger OnValidate()
                    begin
                        Rec.ShowShortcutDimCode(ShortcutDimCode);
                    end;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies an account type for Contrato usage to be posted in the Contrato journal. You can choose from the following options:';

                    trigger OnValidate()
                    begin
                        ContratoJnlManagement.GetNames(Rec, ContratoDescription, AccName);
                    end;
                }
                field("Price Calculation Method"; Rec."Price Calculation Method")
                {
                    Visible = ExtendedPriceEnabled;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the method that will be used for price calculation in the item journal line.';
                }
                field("Cost Calculation Method"; Rec."Cost Calculation Method")
                {
                    Visible = ExtendedPriceEnabled;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the method that will be used for cost calculation in the item journal line.';
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the number of the involved entry or record, according to the specified number series.';

                    trigger OnValidate()
                    begin
                        ContratoJnlManagement.GetNames(Rec, ContratoDescription, AccName);
                        Rec.ShowShortcutDimCode(ShortcutDimCode);
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the name of the resource, item, or general ledger account to which this entry applies. You can change the description.';
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies information in addition to the description.';
                    Visible = false;
                }
                field("Contrato Planning Line No."; Rec."Contrato Planning Line No.")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the Contrato planning line number that the usage should be linked to when the Contrato journal is posted. You can only link to Contrato planning lines that have the Apply Usage Link option enabled.';
                    Visible = false;
                }
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the vendor''s or customer''s trade type to link transactions made for this business partner with the appropriate general ledger account according to the general posting setup.';
                    Visible = false;
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the item''s product type to link transactions made for this item with the appropriate general ledger account according to the general posting setup.';
                    Visible = false;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    Visible = false;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Location;
                    ToolTip = 'Specifies a location code for an item.';
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the bin where the items are picked or put away.';
                }
                field("Work Type Code"; Rec."Work Type Code")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies which work type the resource applies to. Prices are updated based on this entry.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the Contrato''s currency code that listed in the Currency Code field in the Contrato Card. You can only create a Contrato Journal using this currency code.';
                    Visible = false;

                    trigger OnAssistEdit()
                    var
                        ChangeExchangeRate: Page "Change Exchange Rate";
                    begin
                        ChangeExchangeRate.SetParameter(Rec."Currency Code", Rec."Currency Factor", Rec."Posting Date");
                        if ChangeExchangeRate.RunModal() = ACTION::OK then
                            Rec.Validate("Currency Factor", ChangeExchangeRate.GetParameter());

                        Clear(ChangeExchangeRate);
                    end;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the number of units of the Contrato journal''s No. field, that is, either the resource, item, or G/L account number, that applies. If you later change the value in the No. field, the quantity does not change on the journal line.';
                }
                field("Remaining Qty."; Rec."Remaining Qty.")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the quantity of the resource or item that remains to complete a Contrato. The remaining quantity is calculated as the difference between Quantity and Qty. Posted. You can modify this field to indicate the quantity you want to remain on the Contrato planning line after you post usage.';
                    Visible = false;
                }
#if not CLEAN25
                field(QuantityToTransferToInvoice; Rec."Qty. to Transfer to Invoice")
                {
                    ApplicationArea = Contratos;
                    Visible = false;
                    ToolTip = 'Specifies the number of units of the Contrato journal''s No. field, that is, either the resource, item, or G/L account number, that applies. If you later change the value in the No. field, the quantity does not change on the journal line.';
                    ObsoleteReason = 'Field Service is moved to Field Service Integration app.';
                    ObsoleteState = Pending;
                    ObsoleteTag = '25.0';
                }
#endif
                field("Direct Unit Cost (LCY)"; Rec."Direct Unit Cost (LCY)")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the cost, in the local currency, of one unit of the selected item or resource.';
                    Visible = false;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the cost of one unit of the item or resource on the line.';
                }
                field("Unit Cost (LCY)"; Rec."Unit Cost (LCY)")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the cost, in LCY, of one unit of the item or resource on the line.';
                }
                field("Total Cost"; Rec."Total Cost")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the total cost for the journal line. The total cost is calculated based on the Contrato currency, which comes from the Currency Code field on the Contrato card.';
                }
                field("Total Cost (LCY)"; Rec."Total Cost (LCY)")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the total cost for this journal line. The amount is in the local currency.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the price of one unit of the item or resource. You can enter a price manually or have it entered according to the Price/Profit Calculation field on the related card.';
                }
                field("Unit Price (LCY)"; Rec."Unit Price (LCY)")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the price, in LCY, of one unit of the item or resource. You can enter a price manually or have it entered according to the Price/Profit Calculation field on the related card.';
                    Visible = false;
                }
                field("Line Amount"; Rec."Line Amount")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the amount that will be posted to the Contrato ledger.';
                }
                field("Line Amount (LCY)"; Rec."Line Amount (LCY)")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the amount in the local currency that will be posted to the Contrato ledger.';
                    Visible = false;
                }
                field("Line Discount Amount"; Rec."Line Discount Amount")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the discount amount that is granted for the item on the line.';
                }
                field("Line Discount %"; Rec."Line Discount %")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the line discount percentage.';
                }
                field("Total Price"; Rec."Total Price")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the total price in the Contrato currency on the journal line.';
                    Visible = false;
                }
                field("Total Price (LCY)"; Rec."Total Price (LCY)")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the total price for the journal line. The amount is in the local currency.';
                    Visible = false;
                }
                field("Applies-to Entry"; Rec."Applies-to Entry")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies if the Contrato journal line has of type Item and the usage of the item will be applied to an already-posted item ledger entry. If this is the case, enter the entry number that the usage will be applied to.';
                }
                field("Applies-from Entry"; Rec."Applies-from Entry")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the number of the item ledger entry that the journal line costs have been applied from. This should be done when you reverse the usage of an item in a Contrato and you want to return the item to inventory at the same cost as before it was used in the Contrato.';
                    Visible = false;
                }
                field("Country/Region Code"; Rec."Country/Region Code")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the country/region of the address.';
                    Visible = false;
                }
                field("Transaction Type"; Rec."Transaction Type")
                {
                    ApplicationArea = BasicEU, BasicNO;
                    ToolTip = 'Specifies the type of transaction that the document represents, for the purpose of reporting to INTRASTAT.';
                    Visible = false;
                }
                field("Transport Method"; Rec."Transport Method")
                {
                    ApplicationArea = BasicEU, BasicNO;
                    ToolTip = 'Specifies the transport method, for the purpose of reporting to INTRASTAT.';
                    Visible = false;
                }
                field("Time Sheet No."; Rec."Time Sheet No.")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the number of a time sheet. A number is assigned to each time sheet when it is created. You cannot edit the number.';
                    Visible = false;
                }
                field("Time Sheet Line No."; Rec."Time Sheet Line No.")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the line number for a time sheet.';
                    Visible = false;
                }
                field("Time Sheet Date"; Rec."Time Sheet Date")
                {
                    ApplicationArea = Contratos;
                    ToolTip = 'Specifies the date that a time sheet is created.';
                    Visible = false;
                }
                field("Shortcut Dimension 1 Code"; Rec."Shortcut Dimension 1 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 1, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = DimVisible1;
                }
                field("Shortcut Dimension 2 Code"; Rec."Shortcut Dimension 2 Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for Shortcut Dimension 2, which is one of two global dimension codes that you set up in the General Ledger Setup window.';
                    Visible = DimVisible2;
                }
                field(ShortcutDimCode3; ShortcutDimCode[3])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,3';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(3),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    Visible = DimVisible3;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(3, ShortcutDimCode[3]);

                        OnAfterValidateShortcutDimCode(Rec, ShortcutDimCode, 3);
                    end;
                }
                field(ShortcutDimCode4; ShortcutDimCode[4])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,4';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(4),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    Visible = DimVisible4;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(4, ShortcutDimCode[4]);

                        OnAfterValidateShortcutDimCode(Rec, ShortcutDimCode, 4);
                    end;
                }
                field(ShortcutDimCode5; ShortcutDimCode[5])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,5';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(5),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    Visible = DimVisible5;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(5, ShortcutDimCode[5]);

                        OnAfterValidateShortcutDimCode(Rec, ShortcutDimCode, 5);
                    end;
                }
                field(ShortcutDimCode6; ShortcutDimCode[6])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,6';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(6),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    Visible = DimVisible6;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(6, ShortcutDimCode[6]);

                        OnAfterValidateShortcutDimCode(Rec, ShortcutDimCode, 6);
                    end;
                }
                field(ShortcutDimCode7; ShortcutDimCode[7])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,7';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(7),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    Visible = DimVisible7;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(7, ShortcutDimCode[7]);

                        OnAfterValidateShortcutDimCode(Rec, ShortcutDimCode, 7);
                    end;
                }
                field(ShortcutDimCode8; ShortcutDimCode[8])
                {
                    ApplicationArea = Dimensions;
                    CaptionClass = '1,2,8';
                    TableRelation = "Dimension Value".Code where("Global Dimension No." = const(8),
                                                                  "Dimension Value Type" = const(Standard),
                                                                  Blocked = const(false));
                    Visible = DimVisible8;

                    trigger OnValidate()
                    begin
                        Rec.ValidateShortcutDimCode(8, ShortcutDimCode[8]);

                        OnAfterValidateShortcutDimCode(Rec, ShortcutDimCode, 8);
                    end;
                }
            }
            group(Control73)
            {
                ShowCaption = false;
                fixed(Control1902114901)
                {
                    ShowCaption = false;
                    group("Number of Lines")
                    {
                        Caption = 'Number of Lines';
                        field(NumberOfJournalRecords; NumberOfRecords)
                        {
                            ApplicationArea = All;
                            AutoFormatType = 1;
                            ShowCaption = false;
                            Editable = false;
                            ToolTip = 'Specifies the number of lines in the current journal batch.';
                        }
                    }
                    group("Contrato Description")
                    {
                        Caption = 'Contrato Description';
                        field(ContratoDescription; ContratoDescription)
                        {
                            ApplicationArea = Contratos;
                            Editable = false;
                            ShowCaption = false;
                            ToolTip = 'Specifies a description of the Contrato.';
                        }
                    }
                    group("Account Name")
                    {
                        Caption = 'Account Name';
                        field(AccName; AccName)
                        {
                            ApplicationArea = Contratos;
                            Caption = 'Account Name';
                            Editable = false;
                            ToolTip = 'Specifies the name of the customer or vendor that the Contrato is related to.';
                        }
                    }
                }
            }
        }
        area(factboxes)
        {
            part(JournalErrorsFactBox; ContratoJournalErrorsFactbox)
            {
                ApplicationArea = Basic, Suite;
                ShowFilter = false;
                Visible = BackgroundErrorCheck;
                SubPageLink = "Journal Template Name" = field("Journal Template Name"),
                              "Journal Batch Name" = field("Journal Batch Name"),
                              "Line No." = field("Line No.");
            }
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
            group("&Line")
            {
                Caption = '&Line';
                Image = Line;
                action(Dimensions)
                {
                    AccessByPermission = TableData Dimension = R;
                    ApplicationArea = Dimensions;
                    Caption = 'Dimensions';
                    Image = Dimensions;
                    ShortCutKey = 'Alt+D';
                    ToolTip = 'View or edit dimensions, such as area, Contrato, or department, that you can assign to sales and purchase documents to distribute costs and analyze transaction history.';

                    trigger OnAction()
                    begin
                        Rec.ShowDimensions();
                        CurrPage.SaveRecord();
                    end;
                }
                action(ItemTrackingLines)
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Item &Tracking Lines';
                    Image = ItemTrackingLines;
                    ShortCutKey = 'Ctrl+Alt+I';
                    ToolTip = 'View or edit serial numbers and lot numbers that are assigned to the item on the document or journal line.';

                    trigger OnAction()
                    begin
                        Rec.OpenItemTrackingLines(false);
                    end;
                }
            }
            group("&Contrato")
            {
                Caption = '&Contrato';
                Image = Job;
                action(Card)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Card';
                    Image = EditLines;
                    RunObject = Page "Contrato Card";
                    RunPageLink = "No." = field("Contrato No.");
                    ShortCutKey = 'Shift+F7';
                    ToolTip = 'View or change detailed information about the record on the document or journal line.';
                }
                action("Ledger E&ntries")
                {
                    ApplicationArea = Contratos;
                    Caption = 'Ledger E&ntries';
                    Image = CustomerLedger;
                    RunObject = Page "Contrato Ledger Entries";
                    RunPageLink = "Contrato No." = field("Contrato No.");
                    RunPageView = sorting("Contrato No.", "Posting Date");
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View the history of transactions that have been posted for the selected record.';
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(CalcRemainingUsage)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Calc. Remaining Usage';
                    Ellipsis = true;
                    Image = CalculateRemainingUsage;
                    ToolTip = 'Calculate the remaining usage for the Contrato. The batch Contrato calculates, for each Contrato task, the difference between scheduled usage of items, resources, and expenses and actual usage posted in Contrato ledger entries. The remaining usage is then displayed in the Contrato journal from where you can post it.';

                    trigger OnAction()
                    var
                        ContratoCalcRemainingUsage: Report "Contrato Calc. Remaining Usage";
                    begin
                        Rec.TestField("Journal Template Name");
                        Rec.TestField("Journal Batch Name");
                        Clear(ContratoCalcRemainingUsage);
                        ContratoCalcRemainingUsage.SetBatch(Rec."Journal Template Name", Rec."Journal Batch Name");
                        ContratoCalcRemainingUsage.SetDocNo(Rec."Document No.");
                        ContratoCalcRemainingUsage.RunModal();
                    end;
                }
                action(SuggestLinesFromTimeSheets)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Suggest Lines from Time Sheets';
                    Ellipsis = true;
                    Image = SuggestLines;
                    ToolTip = 'Fill the journal with lines that exist in the time sheets.';

                    trigger OnAction()
                    var
                        SuggestContratoJnlLines: Report "Suggest Contrato Jnl. Lines";
                    begin
                        SuggestContratoJnlLines.SetContratoJnlLine(Rec);
                        SuggestContratoJnlLines.RunModal();
                    end;
                }
            }
            group("P&osting")
            {
                Caption = 'P&osting';
                Image = Post;
                action(Reconcile)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Reconcile';
                    Image = Reconcile;
                    ShortCutKey = 'Ctrl+F11';
                    ToolTip = 'View what has been reconciled for the Contrato. The window shows the quantity entered on the Contrato journal lines, totaled by unit of measure and by work type.';

                    trigger OnAction()
                    begin
                        // ContratoJnlReconcile.SetContratoJnlLine(Rec);
                        ContratoJnlReconcile.Run();
                    end;
                }
                action("Test Report")
                {
                    ApplicationArea = Contratos;
                    Caption = 'Test Report';
                    Ellipsis = true;
                    Image = TestReport;
                    ToolTip = 'View a test report so that you can find and correct any errors before you perform the actual posting of the journal or document.';

                    trigger OnAction()
                    begin
                        //ReportPrint.PrintContratoJnlLine(Rec);
                    end;
                }
                action("P&ost")
                {
                    ApplicationArea = Contratos;
                    Caption = 'P&ost';
                    Image = PostOrder;
                    ShortCutKey = 'F9';
                    ToolTip = 'Finalize the document or journal by posting the amounts and quantities to the related accounts in your company books.';

                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"Contrato Jnl.-Post", Rec);
                        CurrentJnlBatchName := Rec.GetRangeMax("Journal Batch Name");
                        CurrPage.Update(false);
                    end;
                }
                action(PreviewPosting)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Preview Posting';
                    Image = ViewPostedOrder;
                    ShortCutKey = 'Ctrl+Alt+F9';
                    ToolTip = 'Review the different types of entries that will be created when you post the document or journal.';

                    trigger OnAction()
                    begin
                        ShowPreview();
                        CurrPage.Update(false);
                    end;
                }
                action("Post and &Print")
                {
                    ApplicationArea = Contratos;
                    Caption = 'Post and &Print';
                    Image = PostPrint;
                    ShortCutKey = 'Shift+F9';
                    ToolTip = 'Finalize and prepare to print the document or journal. The values and quantities are posted to the related accounts. A report request window where you can specify what to include on the print-out.';

                    trigger OnAction()
                    begin
                        CODEUNIT.Run(CODEUNIT::"Job Jnl.-Post+Print", Rec);
                        CurrentJnlBatchName := Rec.GetRangeMax("Journal Batch Name");
                        CurrPage.Update(false);
                    end;
                }
            }
            group("Page")
            {
                Caption = 'Page';
                action(EditInExcel)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Edit in Excel';
                    Image = Excel;
                    ToolTip = 'Send the data in the journal to an Excel file for analysis or editing.';
                    Visible = IsSaaSExcelAddinEnabled;
                    AccessByPermission = System "Allow Action Export To Excel" = X;

                    trigger OnAction()
                    var
                        ODataUtility: Codeunit ODataUtility;
                    begin
                        ODataUtility.EditJournalWorksheetInExcel(CurrPage.Caption, CurrPage.ObjectId(false), Rec."Journal Batch Name", Rec."Journal Template Name");
                    end;
                }
                group(Errors)
                {
                    Caption = 'Issues';
                    Image = ErrorLog;
                    Visible = BackgroundErrorCheck;
                    action(ShowLinesWithErrors)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show Lines with Issues';
                        Image = Error;
                        Visible = BackgroundErrorCheck;
                        Enabled = not ShowAllLinesEnabled;
                        ToolTip = 'View a list of journal lines that have issues before you post the journal.';

                        trigger OnAction()
                        begin
                            Rec.SwitchLinesWithErrorsFilter(ShowAllLinesEnabled);
                        end;
                    }
                    action(ShowAllLines)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Show All Lines';
                        Image = ExpandAll;
                        Visible = BackgroundErrorCheck;
                        Enabled = ShowAllLinesEnabled;
                        ToolTip = 'View all journal lines, including lines with and without issues.';

                        trigger OnAction()
                        begin
                            Rec.SwitchLinesWithErrorsFilter(ShowAllLinesEnabled);
                        end;
                    }
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 1.';

                group(Category_Category6)
                {
                    Caption = 'Post/Print', Comment = 'Generated from the PromotedActionCategories property index 5.';
                    ShowAs = SplitButton;

                    actionref("P&ost_Promoted"; "P&ost")
                    {
                    }
                    actionref(PreviewPosting_Promoted; PreviewPosting)
                    {
                    }
                    actionref("Post and &Print_Promoted"; "Post and &Print")
                    {
                    }
                }
                actionref(Reconcile_Promoted; Reconcile)
                {
                }
            }
            group(Category_Category5)
            {
                Caption = 'Prepare', Comment = 'Generated from the PromotedActionCategories property index 4.';

                actionref(SuggestLinesFromTimeSheets_Promoted; SuggestLinesFromTimeSheets)
                {
                }
                actionref(CalcRemainingUsage_Promoted; CalcRemainingUsage)
                {
                }
            }
            group(Category_Category7)
            {
                Caption = 'Contrato', Comment = 'Generated from the PromotedActionCategories property index 6.';

            }
            group(Category_Category8)
            {
                Caption = 'Line', Comment = 'Generated from the PromotedActionCategories property index 7.';

                actionref(ItemTrackingLines_Promoted; ItemTrackingLines)
                {
                }
                actionref(Dimensions_Promoted; Dimensions)
                {
                }
            }
            group(Category_Category4)
            {
                Caption = 'Page', Comment = 'Generated from the PromotedActionCategories property index 3.';

                actionref(EditInExcel_Promoted; EditInExcel)
                {
                }
                actionref(ShowLinesWithErrors_Promoted; ShowLinesWithErrors)
                {
                }
                actionref(ShowAllLines_Promoted; ShowAllLines)
                {
                }
            }
            group(Category_Report)
            {
                Caption = 'Report', Comment = 'Generated from the PromotedActionCategories property index 2.';
            }
        }
    }

    trigger OnAfterGetCurrRecord()
    begin
        ContratoJnlManagement.GetNames(Rec, ContratoDescription, AccName);
        if not (ClientTypeManagement.GetCurrentClientType() in [CLIENTTYPE::SOAP, CLIENTTYPE::OData, CLIENTTYPE::ODataV4, CLIENTTYPE::Api]) then
            NumberOfRecords := Rec.Count();
    end;

    trigger OnAfterGetRecord()
    begin
        Rec.ShowShortcutDimCode(ShortcutDimCode);
    end;

    trigger OnDeleteRecord(): Boolean
    var
        ReserveContratoJnlLine: Codeunit "Contrato Jnl. Line-Reserve";
    begin
        Commit();
        if not ReserveContratoJnlLine.DeleteLineConfirm(Rec) then
            exit(false);
        ReserveContratoJnlLine.DeleteLine(Rec);
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.SetUpNewLine(xRec);
        Clear(ShortcutDimCode);
    end;

    trigger OnOpenPage()
    var
        PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
        ServerSetting: Codeunit "Server Setting";
    begin
        OnBeforeOpenPage(Rec, CurrentJnlBatchName);

        ExtendedPriceEnabled := PriceCalculationMgt.IsExtendedPriceCalculationEnabled();
        IsSaaSExcelAddinEnabled := ServerSetting.GetIsSaasExcelAddinEnabled();
        if ClientTypeManagement.GetCurrentClientType() = CLIENTTYPE::ODataV4 then
            exit;

        SetDimensionsVisibility();

        OpenJournal();
    end;

    var
        ContratoJnlManagement: Codeunit ContratoJnlManagement;
        ReportPrint: Codeunit "Test Report-Print";
        ClientTypeManagement: Codeunit "Client Type Management";
        ContratoJournalErrorsMgt: Codeunit "Contrato Journal Errors Mgt.";
        ContratoJnlReconcile: Page "Job Journal Reconcile";
        ContratoDescription: Text[100];
        AccName: Text[100];
        NumberOfRecords: Integer;
        CurrentJnlBatchName: Code[10];
        ExtendedPriceEnabled: Boolean;
        IsSaaSExcelAddinEnabled: Boolean;
        BackgroundErrorCheck: Boolean;
        ShowAllLinesEnabled: Boolean;

    protected var
        ShortcutDimCode: array[8] of Code[20];
        DimVisible1: Boolean;
        DimVisible2: Boolean;
        DimVisible3: Boolean;
        DimVisible4: Boolean;
        DimVisible5: Boolean;
        DimVisible6: Boolean;
        DimVisible7: Boolean;
        DimVisible8: Boolean;

    local procedure CurrentJnlBatchNameOnAfterVali()
    begin
        CurrPage.SaveRecord();
        ContratoJnlManagement.SetName(CurrentJnlBatchName, Rec);
        SetControlAppearanceFromBatch();
        CurrPage.Update(false);
    end;

    local procedure OpenJournal()
    var
        JnlSelected: Boolean;
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeOpenJournal(Rec, ContratoJnlManagement, CurrentJnlBatchName, IsHandled);
        if IsHandled then
            exit;

        if Rec.IsOpenedFromBatch() then begin
            CurrentJnlBatchName := Rec."Journal Batch Name";
            ContratoJnlManagement.OpenJnl(CurrentJnlBatchName, Rec);
            SetControlAppearanceFromBatch();
            exit;
        end;
        ContratoJnlManagement.TemplateSelection(PAGE::"Contrato Journal", false, Rec, JnlSelected);
        if not JnlSelected then
            Error('');
        ContratoJnlManagement.OpenJnl(CurrentJnlBatchName, Rec);
        SetControlAppearanceFromBatch();
    end;

    local procedure SetDimensionsVisibility()
    var
        DimMgt: Codeunit DimensionManagement;
    begin
        DimVisible1 := false;
        DimVisible2 := false;
        DimVisible3 := false;
        DimVisible4 := false;
        DimVisible5 := false;
        DimVisible6 := false;
        DimVisible7 := false;
        DimVisible8 := false;

        DimMgt.UseShortcutDims(
          DimVisible1, DimVisible2, DimVisible3, DimVisible4, DimVisible5, DimVisible6, DimVisible7, DimVisible8);

        Clear(DimMgt);
    end;

    local procedure SetControlAppearanceFromBatch()
    var
        ContratoJournalBatch: Record "Contrato Journal Batch";
        BackgroundErrorHandlingMgt: Codeunit "Background Error Handling Mgt.";
    begin
        if not ContratoJournalBatch.Get(Rec.GetRangeMax("Journal Template Name"), CurrentJnlBatchName) then
            exit;

        BackgroundErrorCheck := BackgroundErrorHandlingMgt.BackgroundValidationFeatureEnabled();
        ShowAllLinesEnabled := true;
        Rec.SwitchLinesWithErrorsFilter(ShowAllLinesEnabled);
        ContratoJournalErrorsMgt.SetFullBatchCheck(true);
    end;

    local procedure ShowPreview()
    var
        ContratoJnlPost: Codeunit "Contrato Jnl.-Post";
    begin
        ContratoJnlPost.Preview(Rec);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterValidateShortcutDimCode(var ContratoJournalLine: Record "Contrato Journal Line"; var ShortcutDimCode: array[8] of Code[20]; DimIndex: Integer)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOpenPage(var ContratoJournalLine: Record "Contrato Journal Line"; var CurrentJnlBatchName: Code[10])
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeOpenJournal(var ContratoJournalLine: Record "Contrato Journal Line"; var ContratoJnlManagement: Codeunit ContratoJnlManagement; CurrentJnlBatchName: Code[10]; var IsHandled: Boolean)
    begin
    end;
}

