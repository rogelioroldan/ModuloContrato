page 50216 "Contratos Setup"
{
    AccessByPermission = TableData Contrato = R;
    AdditionalSearchTerms = 'Contrato setup, Contrato Setup';
    ApplicationArea = All;
    Caption = 'Contrato Setup';
    DeleteAllowed = false;
    InsertAllowed = false;
    PageType = Card;
    SourceTable = "Contratos Setup";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field("AutomaticUpdateContraItemCost"; Rec."AutomaticUpdateContraItemCost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies in the contratos Setup window that cost changes are automatically adjusted each time the Adjust Cost - Item Entries batch Contrato is run. The adjustment process and its results are the same as when you run the Update contrato Item Cost batch Contrato.';
                }
                field("Apply Usage Link by Default"; Rec."Apply Usage Link by Default")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies whether contrato ledger entries are linked to contrato planning lines by default. Select this check box if you want to apply this setting to all new contratos that you create.';
                }
                field("Allow Sched/Contract Lines Def"; Rec."Allow Sched/Contract Lines Def")
                {
                    ApplicationArea = All;
                    Caption = 'Allow Budget/Billable Lines Def';
                    ToolTip = 'Specifies whether contrato lines can be of type Both Budget and Billable by default. Select this check box if you want to apply this setting to all new contratos that you create.';
                }
                field("Default WIP Method"; Rec."Default WIP Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default method to be used for calculating work in process (WIP). It is applied whenever you create a new contrato, but you can modify the value on the contrato card.';
                }
                field("Default WIP Posting Method"; Rec."Default WIP Posting Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies how the default WIP method is to be applied when posting Work in Process (WIP) to the general ledger. By default, it is applied per contrato.';
                }
                field("Default Contrato Posting Group"; Rec."Default Contrato Posting Group")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the default posting group to be applied when you create a new contrato. This group is used whenever you create a contrato, but you can modify the value on the contrato card.';
                }
                field("Default Task Billing Method"; Rec."Default Task Billing Method")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specify whether to use the customer specified for the contrato for all tasks or allow people to specify different customers. One customer lets you invoice only the customer specified for the contrato. Multiple customers lets you invoice customers specified on each task, which can be different customers.';
                }
                field("Logo Position on Documents"; Rec."Logo Position on Documents")
                {
                    ApplicationArea = All;
                    Importance = Additional;
                    ToolTip = 'Specifies the position of your company logo on business letters and documents.';
                }
                field("Document No. Is Contrato No."; Rec."Document No. Is Contrato No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies that the contrato number is also the document number in the ledger entries posted for the contrato.';
                }
            }
            group(Prices)
            {
                Caption = 'Prices';
                Visible = ExtendedPriceEnabled;
                field("Default Sales Price List Code"; Rec."Default Sales Price List Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the existing sales price list that stores all new price lines created in the price worksheet page.';
                }
                field("Default Purch Price List Code"; Rec."Default Purch Price List Code")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code of the existing purchase price list that stores all new price lines created in the price worksheet page.';
                }
            }
            group(Numbering)
            {
                Caption = 'Numbering';
                field("Contrato Nos."; Rec."Contrato Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to contratos. To see the number series that have been set up in the No. Series table, click the drop-down arrow in the field.';
                }
                field("Contrato WIP Nos."; Rec."Contrato WIP Nos.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to contrato WIP documents. To see the number series that have been set up in the No. Series table, click the drop-down arrow in the field.';
                }
                field("Price List Nos."; Rec."Price List Nos.")
                {
                    ApplicationArea = All;
                    Visible = ExtendedPriceEnabled;
                    ToolTip = 'Specifies the code for the number series that will be used to assign numbers to contrato price lists.';
                }
            }
            group(Archiving)
            {
                Caption = 'Archiving';

                field("Archive Orders"; Rec."Archive Contratos")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies if you want to automatically archive contratos.';
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

    trigger OnOpenPage()
    var
        PriceCalculationMgt: Codeunit "Price Calculation Mgt.";
    begin
        Rec.Reset();
        if not Rec.Get() then begin
            Rec.Init();
            Rec.Insert();
        end;
        ExtendedPriceEnabled := PriceCalculationMgt.IsExtendedPriceCalculationEnabled();
    end;

    var
        ExtendedPriceEnabled: Boolean;
}

