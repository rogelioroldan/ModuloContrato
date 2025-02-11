page 50241 "Contrato Item Prices"
{
    Caption = 'contrato Item Prices';
    PageType = List;
    SourceTable = "Contrato Item Price";

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
                    ToolTip = 'Specifies the number of the contrato task if the item price should only apply to a specific contrato task.';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the item that this price applies to. Choose the field to see the available items.';
                }
                field("Variant Code"; Rec."Variant Code")
                {
                    ApplicationArea = Planning;
                    ToolTip = 'Specifies the variant code if the price that you are setting up should apply to a specific variant of the item.';
                    Visible = false;
                }
                field("Unit of Measure Code"; Rec."Unit of Measure Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how each unit of the item or resource is measured, such as in pieces or hours. By default, the value in the Base Unit of Measure field on the item or resource card is inserted.';
                }
                field("Currency Code"; Rec."Currency Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default currency code that is defined for a contrato. contrato item prices will only be used if the currency code for the contrato item is the same as the currency code set for the contrato.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the price of one unit of the item or resource. You can enter a price manually or have it entered according to the Price/Profit Calculation field on the related card.';
                }
                field("Unit Cost Factor"; Rec."Unit Cost Factor")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the unit cost factor, if you have agreed with your customer that he should pay certain item usage by cost value plus a certain percent value to cover your overhead expenses.';
                }
                field("Line Discount %"; Rec."Line Discount %")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a contrato-specific line discount percent that applies to this line. This is useful, for example, if you want invoice lines for the contrato to show a discount percent.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the description of the item you have entered in the Item No. field.';
                }
                field("Apply Contrato Discount"; Rec."Apply Contrato Discount")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the check box for this field if the contrato-specific discount percent for this item should apply to the contrato. The default line discount for the line that is defined is included when contrato entries are created, but you can modify this value.';
                    Visible = false;
                }
                field("Apply Contrato Price"; Rec."Apply Contrato Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies whether the contrato-specific price or unit cost factor for this item should apply to the contrato. The default contrato price that is defined is included when contrato-related entries are created, but you can modify this value.';
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
