page 50239 "Contrato Resource Prices"
{
    Caption = 'Contrato Resource Prices';
    PageType = List;
    SourceTable = "Contrato Resource Price";
    // ObsoleteState = Pending;
    // ObsoleteReason = 'Replaced by the new implementation (V16) of price calculation.';
    // ObsoleteTag = '16.0';

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
                }
                field("Contrato Task No."; Rec."Contrato Task No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number of the contrato task if the resource price should only apply to a specific contrato task.';
                }
                field(Type; Rec.Type)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the price that you are setting up for the contrato should apply to a resource, to a resource group, or to all resources and resource groups.';
                }
                field("Code"; Rec.Code)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the resource or resource group that this price applies to. The No. must correspond to your selection in the Type field.';
                }
                field("Work Type Code"; Rec."Work Type Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies which work type the resource applies to. Prices are updated based on this entry.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the currency of the sales price if the price that you have set up in this line is in a foreign currency. Choose the field to see the available currency codes.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the price of one unit of the item or resource. You can enter a price manually or have it entered according to the Price/Profit Calculation field on the related card.';
                }
                field("Unit Cost Factor"; Rec."Unit Cost Factor")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit cost factor. If you have agreed with you customer that he should pay for certain resource usage by cost value plus a certain percent value to cover your overhead expenses, you can set up a unit cost factor in this field.';
                }
                field("Line Discount %"; Rec."Line Discount %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a line discount percent that applies to this resource, or resource group. This is useful, for example if you want invoice lines for the contrato to show a discount percent.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the resource, or resource group, you have entered in the Code field.';
                }
                field("Apply Contrato Discount"; Rec."Apply Contrato Discount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether to apply a discount to the contrato. Select this field if the discount percent for this resource or resource group should apply to the contrato, even if the discount percent is zero.';
                    Visible = false;
                }
                field("Apply Contrato Price"; Rec."Apply Contrato Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the price for this resource, or resource group, should apply to the contrato, even if the price is zero.';
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
    }

    trigger OnInit()
    var
        FeaturePriceCalculation: Codeunit "Feature - Price Calculation";
    begin
        FeaturePriceCalculation.FailIfFeatureEnabled();
    end;
}