page 50238 "Contrato No. of Prices FactBox"
{
    Caption = 'Project Details - No. of Prices';
    PageType = CardPart;
    SourceTable = Contrato;

    layout
    {
        area(content)
        {
            field("No."; Rec."No.")
            {
                ApplicationArea = All;
                Caption = 'Project No.';
                ToolTip = 'Specifies the project number.';

                trigger OnDrillDown()
                begin
                    ShowDetails();
                end;
            }
#if not CLEAN23
            field(NoOfResourcePrices; NoOfResourcePrices)
            {
                ApplicationArea = All;
                Caption = 'Resource';
                Visible = not ExtendedPriceEnabled;
                ToolTip = 'Specifies prices for the resource.';
                ObsoleteState = Pending;
                ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
                ObsoleteTag = '16.0';

                trigger OnDrillDown()
                var
                    ContratoResPrice: Record "Contrato Resource Price";
                begin
                    ContratoResPrice.SetRange("Contrato No.", Rec."No.");

                    PAGE.Run(PAGE::"Contrato Resource Prices", ContratoResPrice);
                end;
            }
            field(NoOfItemPrices; NoOfItemPrices)
            {
                ApplicationArea = All;
                Caption = 'Item';
                Visible = not ExtendedPriceEnabled;
                ToolTip = 'Specifies the total usage cost of items associated with this project.';
                ObsoleteState = Pending;
                ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
                ObsoleteTag = '16.0';

                trigger OnDrillDown()
                var
                    ContratoItPrice: Record "Contrato Item Price";
                begin
                    ContratoItPrice.SetRange("Contrato No.", Rec."No.");

                    PAGE.Run(PAGE::"Contrato Item Prices", ContratoItPrice);
                end;
            }
            field(NoOfAccountPrices; NoOfAccountPrices)
            {
                ApplicationArea = All;
                Caption = 'G/L Account';
                Visible = not ExtendedPriceEnabled;
                ToolTip = 'Specifies the sum of values in the Project G/L Account Prices window.';
                ObsoleteState = Pending;
                ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
                ObsoleteTag = '16.0';

                trigger OnDrillDown()
                var
                    ContratoAccPrice: Record "Contrato G/L Account Price";
                begin
                    ContratoAccPrice.SetRange("Contrato No.", Rec."No.");

                    PAGE.Run(PAGE::"Contrato G/L Account Prices", ContratoAccPrice);
                end;
            }
#endif
            field(NoOfResPrices; NoOfResourcePrices)
            {
                ApplicationArea = All;
                Caption = 'Resource';
                Visible = ExtendedPriceEnabled;
                ToolTip = 'Specifies prices for the resource.';

                trigger OnDrillDown()
                begin
                    Rec.ShowPriceListLines("Price Type"::Sale, "Price Asset Type"::Resource, "Price Amount Type"::Any);
                end;
            }
            field(NoOfItemsPrices; NoOfItemPrices)
            {
                ApplicationArea = All;
                Caption = 'Item';
                Visible = ExtendedPriceEnabled;
                ToolTip = 'Specifies the total usage cost of items associated with this project.';

                trigger OnDrillDown()
                begin
                    Rec.ShowPriceListLines("Price Type"::Sale, "Price Asset Type"::Item, "Price Amount Type"::Any);
                end;
            }
            field(NoOfAccPrices; NoOfAccountPrices)
            {
                ApplicationArea = All;
                Caption = 'G/L Account';
                Visible = ExtendedPriceEnabled;
                ToolTip = 'Specifies the sum of values in the Project G/L Account Prices window.';

                trigger OnDrillDown()
                begin
                    Rec.ShowPriceListLines("Price Type"::Sale, "Price Asset Type"::"G/L Account", "Price Amount Type"::Any);
                end;
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        CalcNoOfRecords();
    end;

    trigger OnFindRecord(Which: Text): Boolean
    begin
        NoOfResourcePrices := 0;
        NoOfItemPrices := 0;
        NoOfAccountPrices := 0;

        exit(Rec.Find(Which));
    end;

    trigger OnOpenPage()
    begin
        ExtendedPriceEnabled := PriceCalculationMgt.IsExtendedPriceCalculationEnabled();
        CalcNoOfRecords();
    end;

    var
        PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
        NoOfResourcePrices: Integer;
        NoOfItemPrices: Integer;
        NoOfAccountPrices: Integer;
        ExtendedPriceEnabled: Boolean;

    local procedure ShowDetails()
    begin
        PAGE.Run(PAGE::"Contrato Card", Rec);
    end;

    local procedure CalcNoOfRecords(): Boolean;
    var
        PriceListLine: Record "Price List Line";
    begin
#if not CLEAN23
        if CalcOldNoOfRecords() then
            exit;
#endif
        PriceListLine.SetRange(Status, "Price Status"::Active);
        PriceListLine.SetRange("Source Type", "Price Source Type"::Contrato);
        PriceListLine.SetRange("Source No.", Rec."No.");
        PriceListLine.SetRange("Price Type", PriceListLine."Price Type"::Sale);
        PriceListLine.SetRange("Asset Type", PriceListLine."Asset Type"::Resource);
        NoOfResourcePrices := PriceListLine.Count();

        PriceListLine.SetRange("Asset Type", "Price Asset Type"::Item);
        NoOfItemPrices := PriceListLine.Count();

        PriceListLine.SetRange("Asset Type", "Price Asset Type"::"G/L Account");
        NoOfAccountPrices := PriceListLine.Count();
    end;

#if not CLEAN23
    local procedure CalcOldNoOfRecords(): Boolean;
    var
        ContratoResourcePrice: Record "Contrato Resource Price";
        ContratoItemPrice: Record "Contrato Item Price";
        ContratoAccountPrice: Record "Contrato G/L Account Price";
    begin
        if PriceCalculationMgt.IsExtendedPriceCalculationEnabled() then
            exit(false);

        ContratoResourcePrice.Reset();
        ContratoResourcePrice.SetRange("Contrato No.", Rec."No.");
        NoOfResourcePrices := ContratoResourcePrice.Count();

        ContratoItemPrice.Reset();
        ContratoItemPrice.SetRange("Contrato No.", Rec."No.");
        NoOfItemPrices := ContratoItemPrice.Count();

        ContratoAccountPrice.Reset();
        ContratoAccountPrice.SetRange("Contrato No.", Rec."No.");
        NoOfAccountPrices := ContratoAccountPrice.Count();
        exit(true);
    end;
#endif
}

