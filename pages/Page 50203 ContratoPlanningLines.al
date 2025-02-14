page 50203 "Contrato Planning Lines"
{
    AutoSplitKey = true;
    Caption = 'Contrato Planning Lines';
    DataCaptionExpression = Rec.Caption();
    PageType = List;
    SourceTable = "Contrato Planning Line";

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
                    ToolTip = 'Specifies the number of the related contrato.';
                    Visible = false;
                }
                field("Contrato Task No."; Rec."Contrato Task No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the related contrato task.';
                    Visible = ContratoTaskNoVisible;
                }
                field("Line Type"; Rec."Line Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the type of planning line.';
                }
                field("Usage Link"; Rec."Usage Link")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the Usage Link field applies to the contrato planning line. When this check box is selected, usage entries are linked to the contrato planning line. Selecting this check box creates a link to the contrato planning line from places where usage has been posted, such as the contrato journal or a purchase line. You can select this check box only if the line type of the contrato planning line is Budget or Both Budget and Billable.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        UsageLinkOnAfterValidate();
                    end;
                }
                field("Planning Date"; Rec."Planning Date")
                {
                    ApplicationArea = All;
                    Editable = PlanningDateEditable;
                    ToolTip = 'Specifies the date of the planning line. You can use the planning date for filtering the totals of the contrato, for example, if you want to see the scheduled usage for a specific month of the year.';

                    trigger OnValidate()
                    begin
                        PlanningDateOnAfterValidate();
                    end;
                }
                field("Planned Delivery Date"; Rec."Planned Delivery Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date that is planned to deliver the item connected to the contrato planning line. For a resource, the planned delivery date is the date that the resource performs services with respect to the contrato.';
                }
                field("Currency Date"; Rec."Currency Date")
                {
                    ApplicationArea = All;
                    Editable = CurrencyDateEditable;
                    ToolTip = 'Specifies the date that will be used to find the exchange rate for the currency in the Currency Date field.';
                    Visible = false;
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    Editable = DocumentNoEditable;
                    ToolTip = 'Specifies a document number for the planning line.';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the planning line''s entry number.';
                    Visible = false;
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    Editable = TypeEditable;
                    ToolTip = 'Specifies the type of account to which the planning line relates.';

                    trigger OnValidate()
                    begin
                        NoOnAfterValidate();
                    end;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Editable = NoEditable;
                    ToolTip = 'Specifies the number of the account to which the resource, item or general ledger account is posted, depending on your selection in the Type field.';

                    trigger OnValidate()
                    var
                        Item: Record "Item";
                    begin
                        NoOnAfterValidate();
                        if Rec."Variant Code" = '' then
                            VariantCodeMandatory := Item.IsVariantMandatory(Rec.Type = Rec.Type::Item, Rec."No.");
                    end;
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Editable = DescriptionEditable;
                    ToolTip = 'Specifies the name of the resource, item, or G/L account to which this entry applies. You can change the description.';
                }
                field("Description 2"; Rec."Description 2")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies information in addition to the description.';
                    Visible = false;
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
                field("Gen. Bus. Posting Group"; Rec."Gen. Bus. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the vendor''s or customer''s trade type to link transactions made for this business partner with the appropriate general ledger account according to the general posting setup.';
                    Visible = false;
                }
                field("Gen. Prod. Posting Group"; Rec."Gen. Prod. Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item''s product type to link transactions made for this item with the appropriate general ledger account according to the general posting setup.';
                    Visible = false;
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Planning;
                    Editable = VariantCodeEditable;
                    ToolTip = 'Specifies the variant of the item on the line.';
                    Visible = false;
                    ShowMandatory = VariantCodeMandatory;

                    trigger OnValidate()
                    var
                        Item: Record "Item";
                    begin
                        VariantCodeOnAfterValidate();
                        if Rec."Variant Code" = '' then
                            VariantCodeMandatory := Item.IsVariantMandatory(Rec.Type = Rec.Type::Item, Rec."No.");
                    end;
                }
                field("Location Code"; Rec."Location Code")
                {
                    ApplicationArea = Location;
                    Editable = LocationCodeEditable;
                    ToolTip = 'Specifies a location code for an item.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        LocationCodeOnAfterValidate();
                    end;
                }
                field("Bin Code"; Rec."Bin Code")
                {
                    ApplicationArea = Warehouse;
                    Editable = BinCodeEditable;
                    ToolTip = 'Specifies the bin where the selected item will be put away or picked in warehouse and inventory processes. If you specify a bin code in the To-Contrato Bin Code field on the Location page, that bin will be suggested when you choose the location.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        BinCodeOnAfterValidate();
                    end;
                }
                field("Work Type Code"; Rec."Work Type Code")
                {
                    ApplicationArea = All;
                    Editable = WorkTypeCodeEditable;
                    ToolTip = 'Specifies which work type the resource applies to. Prices are updated based on this entry.';
                    Visible = false;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    Editable = UnitOfMeasureCodeEditable;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        UnitofMeasureCodeOnAfterValidate();
                    end;
                }
                field(ReserveName; Rec.Reserve)
                {
                    ApplicationArea = Reservation;
                    ToolTip = 'Specifies whether or not a reservation can be made for items on the current line. The field is not applicable if the Type field is set to Resource, Cost, or G/L Account.';
                    Visible = false;

                    trigger OnValidate()
                    begin
                        ReserveOnAfterValidate();
                    end;
                }
                field(GrupoFacturar; Rec.GrupoFacturar)
                {
                    ApplicationArea = All;
                }
                field(Quantity; Rec.Quantity)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of units of the resource, item, or general ledger account that should be specified on the planning line. If you later change the No., the quantity you have entered remains on the line.';

                    trigger OnValidate()
                    begin
                        QuantityOnAfterValidate();
                    end;
                }
                field("Qty. to Assemble"; Rec."Qty. to Assemble")
                {
                    ApplicationArea = Assembly;
                    BlankZero = true;
                    ToolTip = 'Specifies how many units of the contrato planning line quantity that you want to supply by assembly.';
                    Visible = true;

                    trigger OnDrillDown()
                    begin
                        Rec.ShowAsmToContratoPlanningLines();
                    end;

                    trigger OnValidate()
                    begin
                        QtyToAsmOnAfterValidate();
                    end;
                }
                field("Reserved Quantity"; Rec."Reserved Quantity")
                {
                    ApplicationArea = Reservation;
                    ToolTip = 'Specifies the quantity of the item that is reserved for the contrato planning line.';
                    Visible = false;
                }
                field("Quantity (Base)"; Rec."Quantity (Base)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity expressed in the base units of measure.';
                    Visible = false;
                }
                field("Remaining Qty."; Rec."Remaining Qty.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the remaining quantity of the resource, item, or G/L Account that remains to complete a contrato. The quantity is calculated as the difference between Quantity and Qty. Posted.';
                    Visible = false;
                }
                field("Direct Unit Cost (LCY)"; Rec."Direct Unit Cost (LCY)")
                {
                    ApplicationArea = All;
                    Editable = false;
                    ToolTip = 'Specifies the cost, in the local currency, of one unit of the selected item or resource.';
                    Visible = false;
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = All;
                    Editable = UnitCostEditable;
                    ToolTip = 'Specifies the cost of one unit of the item or resource on the line.';
                }
                field("Unit Cost (LCY)"; Rec."Unit Cost (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the cost, in LCY, of one unit of the item or resource on the line.';
                    Visible = false;
                }
                field("Total Cost"; Rec."Total Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total cost for the planning line. The total cost is in the contrato currency, which comes from the Currency Code field in the Contrato Card.';
                }
                field("Remaining Total Cost"; Rec."Remaining Total Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the remaining total cost for the planning line. The total cost is in the contrato currency, which comes from the Currency Code field in the Contrato Card.';
                    Visible = false;
                }
                field("Total Cost (LCY)"; Rec."Total Cost (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total cost for the planning line. The amount is in the local currency.';
                    Visible = false;
                }
                field("Remaining Total Cost (LCY)"; Rec."Remaining Total Cost (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the remaining total cost (LCY) for the planning line. The amount is in the local currency.';
                    Visible = false;
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    Editable = UnitPriceEditable;
                    ToolTip = 'Specifies the price of one unit of the item or resource. You can enter a price manually or have it entered according to the Price/Profit Calculation field on the related card.';
                }
                field("Unit Price (LCY)"; Rec."Unit Price (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the price, in LCY, of one unit of the item or resource. You can enter a price manually or have it entered according to the Price/Profit Calculation field on the related card.';
                    Visible = false;
                }
                field("Line Amount"; Rec."Line Amount")
                {
                    ApplicationArea = All;
                    Editable = LineAmountEditable;
                    ToolTip = 'Specifies the amount that will be posted to the contrato ledger.';
                }
                field("Remaining Line Amount"; Rec."Remaining Line Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount that will be posted to the contrato ledger.';
                    Visible = false;
                }
                field("Line Amount (LCY)"; Rec."Line Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount in the local currency that will be posted to the contrato ledger.';
                    Visible = false;
                }
                field("Remaining Line Amount (LCY)"; Rec."Remaining Line Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount in the local currency that will be posted to the contrato ledger.';
                    Visible = false;
                }
                field("Line Discount Amount"; Rec."Line Discount Amount")
                {
                    ApplicationArea = All;
                    Editable = LineDiscountAmountEditable;
                    ToolTip = 'Specifies the discount amount that is granted for the item on the line.';
                    Visible = false;
                }
                field("Line Discount %"; Rec."Line Discount %")
                {
                    ApplicationArea = All;
                    Editable = LineDiscountPctEditable;
                    ToolTip = 'Specifies the discount percentage that is granted for the item on the line.';
                    Visible = false;
                }
                field("Total Price"; Rec."Total Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total price in the contrato currency on the planning line.';
                    Visible = false;
                }
                field("Total Price (LCY)"; Rec."Total Price (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total price on the planning line. The total price is in the local currency.';
                    Visible = false;
                }
                field("Qty. Posted"; Rec."Qty. Posted")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity that has been posted to the contrato ledger, if the Usage Link check box has been selected.';
                    Visible = false;
                }
                field("Qty. to Transfer to Journal"; Rec."Qty. to Transfer to Journal")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity you want to transfer to the contrato journal. Its default value is calculated as quantity minus the quantity that has already been posted, if the Apply Usage Link check box has been selected.';
                }
                field("Posted Total Cost"; Rec."Posted Total Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total cost that has been posted to the contrato ledger, if the Usage Link check box has been selected.';
                    Visible = false;
                }
                field("Posted Total Cost (LCY)"; Rec."Posted Total Cost (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the total cost (LCY) that has been posted to the contrato ledger, if the Usage Link check box has been selected.';
                    Visible = false;
                }
                field("Posted Line Amount"; Rec."Posted Line Amount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount that has been posted to the contrato ledger. This field is only filled in if the Apply Usage Link check box selected on the contrato card.';
                    Visible = false;
                }
                field("Posted Line Amount (LCY)"; Rec."Posted Line Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount in the local currency that has been posted to the contrato ledger. This field is only filled in if the Apply Usage Link check box selected on the contrato card.';
                    Visible = false;
                }
                field("Qty. Transferred to Invoice"; Rec."Qty. Transferred to Invoice")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity that has been transferred to a sales invoice or credit memo.';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownContratoInvoices();
                    end;
                }
                field("Qty. to Transfer to Invoice"; Rec."Qty. to Transfer to Invoice")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity you want to transfer to the sales invoice or credit memo. The value in this field is calculated as Quantity - Qty. Transferred to Invoice.';
                    Visible = false;
                }
                field("Qty. Invoiced"; Rec."Qty. Invoiced")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity that been posted through a sales invoice.';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownContratoInvoices();
                    end;
                }
                field("Qty. to Invoice"; Rec."Qty. to Invoice")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity that remains to be invoiced. It is calculated as Quantity - Qty. Invoiced.';
                    Visible = false;
                }
                field("Invoiced Amount (LCY)"; Rec."Invoiced Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies, in local currency, the sales amount that was invoiced for this planning line.';

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownContratoInvoices();
                    end;
                }
                field("Invoiced Cost Amount (LCY)"; Rec."Invoiced Cost Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies, in the local currency, the cost amount that was invoiced for this planning line.';
                    Visible = false;

                    trigger OnDrillDown()
                    begin
                        Rec.DrillDownContratoInvoices();
                    end;
                }
                field("User ID"; Rec."User ID")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the ID of the user who posted the entry, to be used, for example, in the change log.';
                    Visible = false;

                    trigger OnDrillDown()
                    var
                        UserMgt: Codeunit "User Management";
                    begin
                        UserMgt.DisplayUserInformation(Rec."User ID");
                    end;
                }
                field("Serial No."; Rec."Serial No.")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the serial number that is applied to the posted item if the planning line was created from the posting of a contrato journal line.';
                    Visible = false;
                }
                field("Lot No."; Rec."Lot No.")
                {
                    ApplicationArea = ItemTracking;
                    ToolTip = 'Specifies the lot number that is applied to the posted item if the planning line was created from the posting of a contrato journal line.';
                    Visible = false;
                }
                field("Contrato Contract Entry No."; Rec."Contrato Contract Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry number of the contrato planning line that the sales line is linked to.';
                    Visible = false;
                }
                field("Ledger Entry Type"; Rec."Ledger Entry Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry type of the contrato ledger entry associated with the planning line.';
                    Visible = false;
                }
                field("Ledger Entry No."; Rec."Ledger Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the entry number of the contrato ledger entry associated with the contrato planning line.';
                    Visible = false;
                }
                field("System-Created Entry"; Rec."System-Created Entry")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies that an entry has been created by Business Central and is related to a contrato ledger entry. The check box is selected automatically.';
                    Visible = false;
                }
                field(Overdue; Rec.Overdue())
                {
                    ApplicationArea = All;
                    Caption = 'Overdue';
                    Editable = false;
                    ToolTip = 'Specifies that the contrato is overdue. ';
                    Visible = false;
                }
                field("Qty. Picked"; Rec."Qty. Picked")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the quantity of the item you have picked for the contrato planning line.';
                    Visible = false;
                }
                field("Qty. Picked (Base)"; Rec."Qty. Picked (Base)")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies the base quantity of the item you have picked for the contrato planning line.';
                    Visible = false;
                }
                field("Contract Line"; Rec."Contract Line")
                {
                    ApplicationArea = Warehouse;
                    ToolTip = 'Specifies whether this line is a billable line.';
                    Visible = false;
                }
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
            group("Contrato Planning &Line")
            {
                Caption = 'Contrato Planning &Line';
                Image = Line;
                action("Linked Contrato Ledger E&ntries")
                {
                    ApplicationArea = Suite;
                    Caption = 'Linked Contrato Ledger E&ntries';
                    Image = JobLedger;
                    ShortCutKey = 'Ctrl+F7';
                    ToolTip = 'View contrato ledger entries related to the contrato planning line.';

                    trigger OnAction()
                    var
                        ContratoLedgerEntry: Record "Contrato Ledger Entry";
                        ContratoUsageLink: Record "Contrato Usage Link";
                        ContratoLedgerEntries: Page "Contrato Ledger Entries";
                    begin
                        ContratoUsageLink.SetRange("Contrato No.", Rec."Contrato No.");
                        ContratoUsageLink.SetRange("Contrato Task No.", Rec."Contrato Task No.");
                        ContratoUsageLink.SetRange("Line No.", Rec."Line No.");
                        if ContratoUsageLink.FindSet() then
                            repeat
                                ContratoLedgerEntry.Get(ContratoUsageLink."Entry No.");
                                ContratoLedgerEntry.Mark := true;
                            until ContratoUsageLink.Next() = 0;

                        ContratoLedgerEntry.MarkedOnly(true);
                        Clear(ContratoLedgerEntries);
                        ContratoLedgerEntries.SetTableView(ContratoLedgerEntry);
                        ContratoLedgerEntries.Run();
                    end;
                }
                action("&Reservation Entries")
                {
                    AccessByPermission = TableData Item = R;
                    ApplicationArea = Reservation;
                    Caption = '&Reservation Entries';
                    Image = ReservationLedger;
                    ToolTip = 'View all reservations that are made for the item, either manually or automatically.';

                    trigger OnAction()
                    begin
                        Rec.ShowReservationEntries(true);
                    end;
                }
                separator(Action133)
                {
                }
                action(OrderPromising)
                {
                    ApplicationArea = OrderPromising;
                    Caption = 'Order &Promising';
                    Image = OrderPromising;
                    ToolTip = 'Calculate the shipment and delivery dates based on the item''s known and expected availability dates, and then promise the dates to the customer.';

                    trigger OnAction()
                    begin
                        Rec.ShowOrderPromisingLine();
                    end;
                }
                action(SendToCalendar)
                {
                    AccessByPermission = TableData "ContratoPlanningLine-Calendar" = RIM;
                    ApplicationArea = All;
                    Caption = 'Send to Calendar';
                    Image = CalendarChanged;
                    RunObject = Codeunit "ContratoPlanningLine-Calendar";
                    RunPageOnRec = true;
                    ToolTip = 'Create a calendar appointment for the resource on each contrato planning line.';
                    Visible = CanSendToCalendar;
                }
                action("Put-away/Pick Lines/Movement Lines")
                {
                    ApplicationArea = Warehouse;
                    Caption = 'Put-away/Pick Lines/Movement Lines';
                    Image = PutawayLines;
                    RunObject = Page "Warehouse Activity Lines";
                    RunPageLink = "Source Type" = filter(167),
                                  "Source Subtype" = const("0"),
                                  "Source No." = field("Contrato No."),
                                  "Source Line No." = field("Contrato Contract Entry No.");
                    ToolTip = 'View the list of ongoing inventory put-aways, picks, or movements for the contrato.';
                }
                action(ItemTrackingLines)
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Item Tracking Lines';
                    Image = ItemTrackingLines;
                    ShortCutKey = 'Ctrl+Alt+I';
                    ToolTip = 'View or edit serial numbers and lot numbers that are assigned to the item on the contrato planning line.';

                    trigger OnAction()
                    begin
                        Rec.OpenItemTrackingLines();
                    end;
                }
                group("Assemble to Order")
                {
                    Caption = 'Assemble to Order';
                    Image = AssemblyBOM;
                    action(AssembleToOrderLines)
                    {
                        AccessByPermission = TableData "BOM Component" = R;
                        ApplicationArea = Assembly;
                        Image = AssemblyBOM;
                        Caption = 'Assemble-to-Order Lines';
                        ToolTip = 'View any linked assembly order lines if the documents represents an assemble-to-order contrato.';

                        trigger OnAction()
                        begin
                            Rec.ShowAsmToContratoPlanningLines();
                        end;
                    }
                }
            }
        }
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
                action(CreateContratoJournalLines)
                {
                    ApplicationArea = All;
                    Caption = 'Create Contrato &Journal Lines';
                    Image = PostOrder;
                    ToolTip = 'Use a batch Contrato to help you create sales journal lines for the involved contrato planning lines.';

                    trigger OnAction()
                    var
                        ContratoPlanningLine: Record "Contrato Planning Line";
                        ContratoJnlLine: Record "Contrato Journal Line";
                        ContratoTransferLine: Codeunit "Contrato Transfer Line";
                        ContratoTransferContratoPlanningLine: Page "ContrTransferContrPlanningLine";
                    begin
                        if ContratoTransferContratoPlanningLine.RunModal() = ACTION::OK then begin
                            ContratoPlanningLine.Copy(Rec);
                            CurrPage.SetSelectionFilter(ContratoPlanningLine);

                            ContratoPlanningLine.SetFilter(Type, '<>%1', ContratoPlanningLine.Type::Text);
                            if ContratoPlanningLine.FindSet() then
                                repeat
                                    ContratoTransferLine.FromPlanningLineToJnlLine(
                                      ContratoPlanningLine, ContratoTransferContratoPlanningLine.GetPostingDate(), ContratoTransferContratoPlanningLine.GetContratoJournalTemplateName(),
                                      ContratoTransferContratoPlanningLine.GetContratoJournalBatchName(), ContratoJnlLine);
                                until ContratoPlanningLine.Next() = 0;

                            CurrPage.Update(false);
                            Message(Text002, ContratoPlanningLine.TableCaption(), ContratoJnlLine.TableCaption());
                        end;
                    end;
                }
                action("&Open Contrato Journal")
                {
                    ApplicationArea = All;
                    Caption = '&Open Contrato Journal';
                    Image = Journals;
                    RunObject = Page "Contrato Journal";
                    RunPageLink = "Contrato No." = field("Contrato No."),
                                  "Contrato Task No." = field("Contrato Task No.");
                    ToolTip = 'Open the contrato journal, for example, to post usage for a contrato.';
                }
                separator(Action16)
                {
                }
                action("Create &Sales Invoice")
                {
                    ApplicationArea = All;
                    Caption = 'Create &Sales Invoice';
                    Ellipsis = true;
                    Image = JobSalesInvoice;
                    ToolTip = 'Use a batch Contrato to help you create sales invoices for the involved contrato tasks.';

                    trigger OnAction()
                    var
                        IsHandled: Boolean;
                    begin
                        IsHandled := false;
                        OnCreateSalesInvoiceOnBeforeAction(Rec, IsHandled);
                        if not IsHandled then
                            CreateSalesInvoice(false);
                    end;
                }
                action("Create Sales &Credit Memo")
                {
                    ApplicationArea = All;
                    Caption = 'Create Sales &Credit Memo';
                    Ellipsis = true;
                    Image = CreditMemo;
                    ToolTip = 'Create a sales credit memo for the selected contrato planning line.';

                    trigger OnAction()
                    var
                        IsHandled: Boolean;
                    begin
                        IsHandled := false;
                        OnCreateSalesCreditMemoOnBeforeAction(Rec, IsHandled);
                        if not IsHandled then
                            CreateSalesInvoice(true);
                    end;
                }
                action("Sales &Invoices/Credit Memos")
                {
                    ApplicationArea = All;
                    Caption = 'Sales &Invoices/Credit Memos';
                    Ellipsis = true;
                    Image = GetSourceDoc;
                    ToolTip = 'View sales invoices or sales credit memos that are related to the selected contrato.';

                    trigger OnAction()
                    begin
                        ContratoCreateInvoice.GetContratoPlanningLineInvoices(Rec);
                    end;
                }
                separator(Action123)
                {
                }
                action(Reserve)
                {
                    ApplicationArea = Reservation;
                    Caption = '&Reserve';
                    Ellipsis = true;
                    Image = Reserve;
                    ToolTip = 'Reserve one or more units of the item on the contrato planning line, either from inventory or from incoming supply.';

                    trigger OnAction()
                    begin
                        Rec.ShowReservation();
                    end;
                }
                action("Order &Tracking")
                {
                    ApplicationArea = ItemTracking;
                    Caption = 'Order &Tracking';
                    Image = OrderTracking;
                    ToolTip = 'Tracks the connection of a supply to its corresponding demand. This can help you find the original demand that created a specific production order or purchase order.';

                    trigger OnAction()
                    begin
                        Rec.ShowTracking();
                    end;
                }
                separator(Action130)
                {
                }
                action(DemandOverview)
                {
                    ApplicationArea = Planning;
                    Caption = '&Demand Overview';
                    Image = Forecast;
                    ToolTip = 'Get an overview of demand planning related to contratos, such as the availability of spare parts or other items that you may use in a contrato. For example, you can determine whether the item you need is in stock, and if it is not, you can determine when the item will be in stock.';

                    trigger OnAction()
                    var
                        DemandOverview: Page "Demand Overview";
                    begin
                        DemandOverview.SetCalculationParameter(true);

                        DemandOverview.Initialize(0D, 3, Rec."Contrato No.", '', '');
                        DemandOverview.RunModal();
                    end;
                }
                action(ExplodeBOM_Functions)
                {
                    AccessByPermission = TableData "BOM Component" = R;
                    ApplicationArea = Suite;
                    Caption = 'E&xplode BOM';
                    Image = ExplodeBOM;
                    ToolTip = 'Add a line for each component on the bill of materials for the selected item. For example, this is useful for selling the parent item as a kit. CAUTION: The line for the parent item will be deleted and only its description will display. To undo this action, delete the component lines and add a line for the parent item again.';

                    trigger OnAction()
                    begin
                        ExplodeBOM();
                    end;
                }
                action(SelectMultiItems)
                {
                    AccessByPermission = TableData Item = R;
                    ApplicationArea = Basic, Suite;
                    Caption = 'Select items';
                    Image = NewItem;
                    Ellipsis = true;
                    Visible = SelectMultipleItemsVisible;
                    ToolTip = 'Add two or more items from the full list of available items.';

                    trigger OnAction()
                    begin
                        Rec.SelectMultipleItems();
                    end;
                }
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
                ToolTip = 'Compare budgeted and usage amounts for selected contratos. All lines of the selected contrato show quantity, total cost, and line amount.';
            }
            action("<Report Contrato Actual to Budget (Price)>")
            {
                ApplicationArea = All;
                Caption = 'Contrato Actual to Budget (Price)';
                Image = "Report";
                RunObject = Report "ContratoActualtoBudget(Price)";
                ToolTip = 'Compare the actual price of your contratos to the price that was budgeted. The report shows budget and actual amounts for each phase, task, and steps.';
            }
            action("Contrato Analysis")
            {
                ApplicationArea = All;
                Caption = 'Contrato Analysis';
                Image = "Report";
                RunObject = Report "Contrato Analysis";
                ToolTip = 'Analyze the contrato, such as the scheduled prices, usage prices, and contract prices, and then compares the three sets of prices.';
            }
            action("Contrato - Planning Lines")
            {
                ApplicationArea = All;
                Caption = 'Contrato - Planning Lines';
                Image = "Report";
                RunObject = Report "Contrato - Planning Lines";
                ToolTip = 'View all planning lines for the contrato. You use this window to plan what items, resources, and general ledger expenses that you expect to use on a contrato (Budget) or you can specify what you actually agreed with your customer that he should pay for the contrato (Billable).';
            }
            action("Contrato - Suggested Billing")
            {
                ApplicationArea = All;
                Caption = 'Contrato - Suggested Billing';
                Image = "Report";
                RunObject = Report "ContratoCostSuggestedBilling";
                ToolTip = 'View a list of all contratos, grouped by customer, how much the customer has already been invoiced, and how much remains to be invoiced, that is, the suggested billing.';
            }
            action("Contratos - Transaction Detail")
            {
                ApplicationArea = All;
                Caption = 'contratos - Transaction Detail';
                Image = "Report";
                //The property 'PromotedCategory' can only be set if the property 'Promoted' is set to 'true'
                //PromotedCategory = "Report";
                RunObject = Report "ContratoCostTransactionDetail";
                ToolTip = 'View all postings with entries for a selected contrato for a selected period, which have been charged to a certain contrato. At the end of each contrato list, the amounts are totaled separately for the Sales and Usage entry types.';
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process', Comment = 'Generated from the PromotedActionCategories property index 1.';

                actionref("Create &Sales Invoice_Promoted"; "Create &Sales Invoice")
                {
                }
                actionref(CreateContratoJournalLines_Promoted; CreateContratoJournalLines)
                {
                }
                actionref("Sales &Invoices/Credit Memos_Promoted"; "Sales &Invoices/Credit Memos")
                {
                }
                actionref("Create Sales &Credit Memo_Promoted"; "Create Sales &Credit Memo")
                {
                }
                actionref(Reserve_Promoted; Reserve)
                {
                }
                actionref(ItemTrackingLines_Promoted; ItemTrackingLines)
                {
                }
                actionref("&Open Contrato Journal_Promoted"; "&Open Contrato Journal")
                {
                }
            }
            group(Category_Category4)
            {
                Caption = 'Outlook', Comment = 'Generated from the PromotedActionCategories property index 3.';

                actionref(SendToCalendar_Promoted; SendToCalendar)
                {
                }
            }
            group(Category_Report)
            {
                Caption = 'Report', Comment = 'Generated from the PromotedActionCategories property index 2.';

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

    trigger OnAfterGetCurrRecord()
    begin
        SetEditable(IsTypeFieldEditable());
    end;

    trigger OnAfterGetRecord()
    var
        Item: Record Item;
    begin
        if Rec."Variant Code" = '' then
            VariantCodeMandatory := Item.IsVariantMandatory(Rec.Type = Rec.Type::Item, Rec."No.");
    end;

    trigger OnInit()
    var
        EmailAccount: Codeunit "Email Account";
        PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
    begin
        UnitCostEditable := true;
        LineAmountEditable := true;
        LineDiscountPctEditable := true;
        LineDiscountAmountEditable := true;
        UnitPriceEditable := true;
        WorkTypeCodeEditable := true;
        LocationCodeEditable := true;
        BinCodeEditable := true;
        VariantCodeEditable := true;
        UnitOfMeasureCodeEditable := true;
        DescriptionEditable := true;
        NoEditable := true;
        TypeEditable := true;
        DocumentNoEditable := true;
        CurrencyDateEditable := true;
        PlanningDateEditable := true;

        ContratoTaskNoVisible := true;

        CanSendToCalendar := EmailAccount.IsAnyAccountRegistered();
        ExtendedPriceEnabled := PriceCalculationMgt.IsExtendedPriceCalculationEnabled();
    end;

    trigger OnModifyRecord(): Boolean
    begin
        if Rec."System-Created Entry" then begin
            if Confirm(Text001, false) then
                Rec."System-Created Entry" := false
            else
                Error('');
        end;
    end;

    trigger OnNewRecord(BelowxRec: Boolean)
    begin
        Rec.SetUpNewLine(xRec);
    end;

    trigger OnOpenPage()
    var
        Contrato: Record Contrato;
    begin
        Rec.FilterGroup := 2;
        if Rec.GetFilter("Contrato No.") <> '' then
            // if Contrato.Get(Rec.GetRangeMin("Contrato No.")) then
            //     CurrPage.Editable(not (Contrato.Blocked = Contrato.Blocked::All));

        SelectMultipleItemsVisible := Rec.GetFilter("Contrato Task No.") <> '';
        Rec.FilterGroup := 0;
    end;

    var
        ContratoCreateInvoice: Codeunit "Contrato Create-Invoice";
        Text001: Label 'This contrato planning line was automatically generated. Do you want to continue?';
        Text002: Label 'The %1 was successfully transferred to a %2.';
        ExtendedPriceEnabled: Boolean;
        VariantCodeMandatory: Boolean;
        SelectMultipleItemsVisible: Boolean;

    protected var
        ContratoTaskNoVisible: Boolean;
        PlanningDateEditable: Boolean;
        CurrencyDateEditable: Boolean;
        DocumentNoEditable: Boolean;
        TypeEditable: Boolean;
        NoEditable: Boolean;
        DescriptionEditable: Boolean;
        UnitOfMeasureCodeEditable: Boolean;
        VariantCodeEditable: Boolean;
        LocationCodeEditable: Boolean;
        BinCodeEditable: Boolean;
        WorkTypeCodeEditable: Boolean;
        UnitPriceEditable: Boolean;
        LineDiscountAmountEditable: Boolean;
        LineDiscountPctEditable: Boolean;
        LineAmountEditable: Boolean;
        UnitCostEditable: Boolean;
        CanSendToCalendar: Boolean;

    local procedure CreateSalesInvoice(CrMemo: Boolean)
    var
        ContratoPlanningLine: Record "Contrato Planning Line";
        ContratoCreateInvoice: Codeunit "Contrato Create-Invoice";
    begin
        Rec.TestField("Line No.");
        ContratoPlanningLine.Copy(Rec);
        CurrPage.SetSelectionFilter(ContratoPlanningLine);
        ContratoCreateInvoice.CreateSalesInvoice(ContratoPlanningLine, CrMemo)
    end;

    protected procedure SetEditable(Edit: Boolean)
    begin
        PlanningDateEditable := Edit;
        CurrencyDateEditable := Edit;
        DocumentNoEditable := Edit;
        TypeEditable := Edit;
        NoEditable := Edit;
        DescriptionEditable := Edit;
        UnitOfMeasureCodeEditable := Edit;
        VariantCodeEditable := Edit;
        LocationCodeEditable := Edit;
        BinCodeEditable := Edit;
        WorkTypeCodeEditable := Edit;
        UnitPriceEditable := Edit;
        LineDiscountAmountEditable := Edit;
        LineDiscountPctEditable := Edit;
        LineAmountEditable := Edit;
        UnitCostEditable := Edit;

        OnAfterSetEditable(Edit, Rec);
    end;

    procedure SetContratoTaskNoVisible(NewContratoTaskNoVisible: Boolean)
    begin
        ContratoTaskNoVisible := NewContratoTaskNoVisible;
    end;

    local procedure PerformAutoReserve()
    begin
        if (Rec.Reserve = Rec.Reserve::Always) and
           (Rec."Remaining Qty. (Base)" <> 0)
        then begin
            CurrPage.SaveRecord();
            Rec.AutoReserve();
            CurrPage.Update(false);
        end;
    end;

    protected procedure UsageLinkOnAfterValidate()
    begin
        PerformAutoReserve();
    end;

    protected procedure PlanningDateOnAfterValidate()
    begin
        if Rec."Planning Date" <> xRec."Planning Date" then
            PerformAutoReserve();
    end;

    protected procedure NoOnAfterValidate()
    begin
        if Rec."No." <> xRec."No." then
            PerformAutoReserve();

        OnAfterNoOnAfterValidate(Rec);
    end;

    protected procedure VariantCodeOnAfterValidate()
    begin
        if Rec."Variant Code" <> xRec."Variant Code" then
            PerformAutoReserve();
    end;

    protected procedure LocationCodeOnAfterValidate()
    begin
        if Rec."Location Code" <> xRec."Location Code" then
            PerformAutoReserve();
    end;

    protected procedure BinCodeOnAfterValidate()
    begin
        if Rec."Bin Code" <> xRec."Bin Code" then
            PerformAutoReserve();
    end;

    protected procedure UnitofMeasureCodeOnAfterValidate()
    begin
        PerformAutoReserve();
    end;

    protected procedure ReserveOnAfterValidate()
    begin
        PerformAutoReserve();
    end;

    protected procedure QtyToAsmOnAfterValidate()
    begin
        PerformAutoReserve();
    end;

    protected procedure QuantityOnAfterValidate()
    begin
        PerformAutoReserve();
        if (Rec.Type = Rec.Type::Item) and (Rec.Quantity <> xRec.Quantity) then
            CurrPage.Update(true);
    end;

    local procedure IsTypeFieldEditable(): Boolean
    var
        ContratoPlanningLineInvoice: Record "Contrato Planning Line Invoice";
        IsHandled, TypeFieldEditable : Boolean;
    begin
        TypeFieldEditable := false;
        IsHandled := false;
        if Rec.Type = Rec.Type::Text then begin
            ContratoPlanningLineInvoice.SetRange("Contrato No.", Rec."Contrato No.");
            ContratoPlanningLineInvoice.SetRange("Contrato Task No.", Rec."Contrato Task No.");
            ContratoPlanningLineInvoice.SetRange("Contrato Planning Line No.", Rec."Line No.");
            OnIsTypeFieldEditableOnAfterFilterContratoPlanningLineInvoice(ContratoPlanningLineInvoice, Rec, TypeFieldEditable, IsHandled);
            if IsHandled then
                exit(TypeFieldEditable);
            exit(ContratoPlanningLineInvoice.IsEmpty());
        end;

        OnAfterIsTypeFieldEditable(Rec, TypeFieldEditable, IsHandled);
        if IsHandled then
            exit(TypeFieldEditable);

        exit(Rec."Qty. Transferred to Invoice" = 0);
    end;

    procedure ExplodeBOM()
    begin
        Codeunit.Run(Codeunit::"Job-Explode BOM", Rec);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterNoOnAfterValidate(var ContratoPlanningLine: Record "Contrato Planning Line")
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnIsTypeFieldEditableOnAfterFilterContratoPlanningLineInvoice(var ContratoPlanningLineInvoice: Record "Contrato Planning Line Invoice"; ContratoPlanningLine: Record "Contrato Planning Line"; var TypeFieldEditable: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterIsTypeFieldEditable(var ContratoPlanningLine: Record "Contrato Planning Line"; var TypeFieldEditable: Boolean; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnCreateSalesCreditMemoOnBeforeAction(var ContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnCreateSalesInvoiceOnBeforeAction(var ContratoPlanningLine: Record "Contrato Planning Line"; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnAfterSetEditable(Edit: Boolean; var ContratoPlanningLine: Record "Contrato Planning Line");
    begin
    end;
}
