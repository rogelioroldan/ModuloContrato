page 50226 "Contrato Planning Lines Part"
{
    AutoSplitKey = true;
    Caption = 'Contrato Planning Lines';
    DataCaptionExpression = Rec.Caption();
    PageType = ListPart;
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
    }

    actions
    {
        area(processing)
        {
            group("F&unctions")
            {
                Caption = 'F&unctions';
                Image = "Action";
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
                action(SelectMultiItems)
                {
                    AccessByPermission = TableData Item = R;
                    ApplicationArea = Basic, Suite;
                    Caption = 'Select items';
                    Image = NewItem;
                    Ellipsis = true;
                    ToolTip = 'Add two or more items from the full list of available items.';

                    trigger OnAction()
                    begin
                        Rec.SelectMultipleItems();
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
        Rec.FilterGroup := 0;
    end;

    var
        ContratoCreateInvoice: Codeunit "Contrato Create-Invoice";
        Text001: Label 'This contrato planning line was automatically generated. Do you want to continue?';
        ExtendedPriceEnabled: Boolean;
        VariantCodeMandatory: Boolean;

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
    local procedure OnAfterSetEditable(Edit: Boolean; var ContratoPlanningLine: Record "Contrato Planning Line");
    begin
    end;
}