page 50214 "Sales Contrato Price Lists"
{
    Caption = 'Sales contrato Price Lists';
    CardPageID = "Sales Price List";
    Editable = false;
    PageType = List;
    QueryCategory = 'Sales Contrato Price Lists';
    RefreshOnActivate = true;
    SourceTable = "Price List Header";
    SourceTableView = where("Source Group" = const(Contrato), "Price Type" = const(Sale));
    ApplicationArea = All;
    UsageCategory = Lists;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field(Code; Rec.Code)
                {
                    ApplicationArea = All;
                    Caption = 'Code';
                    ToolTip = 'Specifies the unique identifier of the price list.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    Caption = 'Description';
                    ToolTip = 'Specifies the description of the price list.';
                }
                field(Status; Rec.Status)
                {
                    ApplicationArea = All;
                    Caption = 'Status';
                    ToolTip = 'Specifies whether the price list is in Draft status and can be edited, Inactive and cannot be edited or used, or Active and can be edited (when Allow Editing Active Price is enabled) and used for price calculations.';
                }
                field("Allow Updating Defaults"; Rec."Allow Updating Defaults")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether users can change the values in the fields on the price list lines that contain default values from the header. This does not affect the ability to allow line or invoice discounts.';
                }
                field(Defines; Rec."Amount Type")
                {
                    ApplicationArea = All;
                    Caption = 'Defines';
                    ToolTip = 'Specifies whether the price list defines prices, discounts, or both.';
                }
                field("Currency Code"; CurrRec."Currency Code")
                {
                    ApplicationArea = All;
                    Caption = 'Currency';
                    ToolTip = 'Specifies the currency that is used on the price list.';
                }
                field(SourceGroup; Rec."Source Group")
                {
                    ApplicationArea = All;
                    Caption = 'Assign-to Group';
                    Visible = false;
                    ToolTip = 'Specifies whether the prices come from groups of customers, vendors or contratos.';
                }
                field(SourceType; CurrRec."Source Type")
                {
                    ApplicationArea = All;
                    Caption = 'Assign-to Type';
                    ToolTip = 'Specifies the type of entity to which the price list is assigned. The options are relevant to the entity you are currently viewing.';
                }
                field(SourceNo; CurrRec."Source No.")
                {
                    ApplicationArea = All;
                    Caption = 'Assign-to';
                    ToolTip = 'Specifies the entity to which the prices are assigned. The options depend on the selection in the Assign-to Type field. If you choose an entity, the price list will be used only for that entity.';
                }
                field(ParentSourceNo; CurrRec."Parent Source No.")
                {
                    ApplicationArea = All;
                    Caption = 'Assign-to contrato No.';
                    ToolTip = 'Specifies the contrato to which the prices are assigned. If you choose an entity, the price list will be used only for that entity.';
                }
                field("Starting Date"; CurrRec."Starting Date")
                {
                    ApplicationArea = All;
                    Caption = 'Starting Date';
                    ToolTip = 'Specifies the date from which the price is valid.';
                }
                field("Ending Date"; CurrRec."Ending Date")
                {
                    ApplicationArea = All;
                    Caption = 'Ending Date';
                    ToolTip = 'Specifies the date when the sales price agreement ends.';
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
        area(Promoted)
        {
            group(Category_Report)
            {
                Caption = 'Report', Comment = 'Generated from the PromotedActionCategories property index 2.';
            }
        }
    }
#if not CLEAN23
    trigger OnInit()
    var
#pragma warning disable AL0432
        FeaturePriceCalculation: Codeunit "Feature - Price Calculation";
#pragma warning restore AL0432
    begin
        FeaturePriceCalculation.FailIfFeatureDisabled();
    end;
#endif
    trigger OnAfterGetRecord()
    begin
        CurrRec := Rec;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        CurrRec := Rec;
    end;

    var
        CurrRec: Record "Price List Header";

    procedure SetRecordFilter(var PriceListHeader: Record "Price List Header")
    begin
        Rec.FilterGroup := 2;
        Rec.CopyFilters(PriceListHeader);
        Rec.SetRange("Source Group", Rec."Source Group"::Contrato);
        Rec.SetRange("Price Type", Rec."Price Type"::Sale);
        Rec.FilterGroup := 0;
    end;

    procedure SetSource(PriceSourceList: Codeunit "Price Source List"; AmountType: Enum "Price Amount Type")
    var
        PriceUXManagement: Codeunit "Price UX Management";
    begin
        PriceUXManagement.SetPriceListsFilters(Rec, PriceSourceList, AmountType);
    end;
}
