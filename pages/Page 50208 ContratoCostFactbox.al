page 50208 "Contrato Cost Factbox"
{
    Caption = 'Contrato Details';
    Editable = false;
    LinksAllowed = false;
    PageType = CardPart;
    SourceTable = Contrato;

    layout
    {
        area(content)
        {
            field("No."; Rec."No.")
            {
                ApplicationArea = All;
                Caption = 'Contrato No.';
                ToolTip = 'Specifies the project number.';

                trigger OnDrillDown()
                begin
                    ShowDetails();
                end;
            }
            group("Budget Cost")
            {
                Caption = 'Budget Cost';
                field(PlaceHolderLbl; PlaceHolderLbl)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'Specifies nothing.';
                    Visible = false;
                }
                field(ScheduleCostLCY; CL[1])
                {
                    ApplicationArea = All;
                    Caption = 'Resource';
                    Editable = false;
                    ToolTip = 'Specifies the total budgeted cost of resources associated with this project.';

                    trigger OnDrillDown()
                    begin
                        ContratoCalcStatistics.ShowPlanningLine(1, true);
                    end;
                }
                field(ScheduleCostLCYItem; CL[2])
                {
                    ApplicationArea = All;
                    Caption = 'Item';
                    Editable = false;
                    ToolTip = 'Specifies the total budgeted cost of items associated with this project.';

                    trigger OnDrillDown()
                    begin
                        ContratoCalcStatistics.ShowPlanningLine(2, true);
                    end;
                }
                field(ScheduleCostLCYGLAcc; CL[3])
                {
                    ApplicationArea = All;
                    Caption = 'G/L Account';
                    Editable = false;
                    ToolTip = 'Specifies the total budgeted cost of general journal entries associated with this project.';

                    trigger OnDrillDown()
                    begin
                        ContratoCalcStatistics.ShowPlanningLine(3, true);
                    end;
                }
                field(ScheduleCostLCYTotal; CL[4])
                {
                    ApplicationArea = All;
                    Caption = 'Total';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = true;
                    ToolTip = 'Specifies the total budget cost of a project.';

                    trigger OnDrillDown()
                    begin
                        ContratoCalcStatistics.ShowPlanningLine(0, true);
                    end;
                }
            }
            group("Actual Cost")
            {
                Caption = 'Actual Cost';
                field(Placeholder2; PlaceHolderLbl)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'Specifies nothing.';
                    Visible = false;
                }
                field(UsageCostLCY; CL[5])
                {
                    ApplicationArea = All;
                    Caption = 'Resource';
                    Editable = false;
                    ToolTip = 'Specifies the total usage cost of resources associated with this project.';

                    trigger OnDrillDown()
                    begin
                        ContratoCalcStatistics.ShowLedgEntry(1, true);
                    end;
                }
                field(UsageCostLCYItem; CL[6])
                {
                    ApplicationArea = All;
                    Caption = 'Item';
                    Editable = false;
                    ToolTip = 'Specifies the total usage cost of items associated with this project.';

                    trigger OnDrillDown()
                    begin
                        ContratoCalcStatistics.ShowLedgEntry(2, true);
                    end;
                }
                field(UsageCostLCYGLAcc; CL[7])
                {
                    ApplicationArea = All;
                    Caption = 'G/L Account';
                    Editable = false;
                    ToolTip = 'Specifies the total usage cost of general journal entries associated with this project.';

                    trigger OnDrillDown()
                    begin
                        ContratoCalcStatistics.ShowLedgEntry(3, true);
                    end;
                }
                field(UsageCostLCYTotal; CL[8])
                {
                    ApplicationArea = All;
                    Caption = 'Total';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = true;
                    ToolTip = 'Specifies the total costs used for a project.';

                    trigger OnDrillDown()
                    begin
                        ContratoCalcStatistics.ShowLedgEntry(0, true);
                    end;
                }
            }
            group("Billable Price")
            {
                Caption = 'Billable Price';
                field(Placeholder3; PlaceHolderLbl)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'Specifies nothing.';
                    Visible = false;
                }
                field(BillablePriceLCY; PL[9])
                {
                    ApplicationArea = All;
                    Caption = 'Resource';
                    Editable = false;
                    ToolTip = 'Specifies the total billable price of resources associated with this project.';

                    trigger OnDrillDown()
                    var
                        IsHandled: Boolean;
                    begin
                        IsHandled := false;
                        OnBeforeOnDrillDownBillablePriceLCY(Rec, IsHandled);
                        if not IsHandled then
                            ContratoCalcStatistics.ShowPlanningLine(1, false);
                    end;
                }
                field(BillablePriceLCYItem; PL[10])
                {
                    ApplicationArea = All;
                    Caption = 'Item';
                    Editable = false;
                    ToolTip = 'Specifies the total billable price of items associated with this project.';

                    trigger OnDrillDown()
                    var
                        IsHandled: Boolean;
                    begin
                        IsHandled := false;
                        OnBeforeOnDrillDownBillablePriceLCYItem(Rec, IsHandled);
                        if not IsHandled then
                            ContratoCalcStatistics.ShowPlanningLine(2, false);
                    end;
                }
                field(BillablePriceLCYGLAcc; PL[11])
                {
                    ApplicationArea = All;
                    Caption = 'G/L Account';
                    Editable = false;
                    ToolTip = 'Specifies the total billable price for project planning lines of type G/L account.';

                    trigger OnDrillDown()
                    var
                        IsHandled: Boolean;
                    begin
                        IsHandled := false;
                        OnBeforeOnDrillDownBillablePriceLCYGLAcc(Rec, IsHandled);
                        if not IsHandled then
                            ContratoCalcStatistics.ShowPlanningLine(3, false);
                    end;
                }
                field(BillablePriceLCYTotal; PL[12])
                {
                    ApplicationArea = All;
                    Caption = 'Total';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = true;
                    ToolTip = 'Specifies the total billable price used for a project.';

                    trigger OnDrillDown()
                    var
                        IsHandled: Boolean;
                    begin
                        IsHandled := false;
                        OnBeforeOnDrillDownBillablePriceLCYTotal(Rec, IsHandled);
                        if not IsHandled then
                            ContratoCalcStatistics.ShowPlanningLine(0, false);
                    end;
                }
            }
            group("Invoiced Price")
            {
                Caption = 'Invoiced Price';
                field(Placeholder4; PlaceHolderLbl)
                {
                    ApplicationArea = All;
                    Editable = false;
                    Enabled = false;
                    ToolTip = 'Specifies nothing.';
                    Visible = false;
                }
                field(InvoicedPriceLCY; PL[13])
                {
                    ApplicationArea = All;
                    Caption = 'Resource';
                    Editable = false;
                    ToolTip = 'Specifies the total invoiced price of resources associated with this project.';

                    trigger OnDrillDown()
                    var
                        IsHandled: Boolean;
                    begin
                        IsHandled := false;
                        OnBeforeOnDrillDownInvoicedPriceLCY(Rec, IsHandled);
                        if not IsHandled then
                            ContratoCalcStatistics.ShowLedgEntry(1, false);
                    end;
                }
                field(InvoicedPriceLCYItem; PL[14])
                {
                    ApplicationArea = All;
                    Caption = 'Item';
                    Editable = false;
                    ToolTip = 'Specifies the total invoiced price of items associated with this project.';

                    trigger OnDrillDown()
                    var
                        IsHandled: Boolean;
                    begin
                        IsHandled := false;
                        OnBeforeOnDrillDownInvoicedPriceLCYItem(Rec, IsHandled);
                        if not IsHandled then
                            ContratoCalcStatistics.ShowLedgEntry(2, false);
                    end;
                }
                field(InvoicedPriceLCYGLAcc; PL[15])
                {
                    ApplicationArea = All;
                    Caption = 'G/L Account';
                    Editable = false;
                    ToolTip = 'Specifies the total invoiced price of general journal entries associated with this project.';

                    trigger OnDrillDown()
                    var
                        IsHandled: Boolean;
                    begin
                        IsHandled := false;
                        OnBeforeOnDrillDownInvoicedPriceLCYGLAcc(Rec, IsHandled);
                        if not IsHandled then
                            ContratoCalcStatistics.ShowLedgEntry(3, false);
                    end;
                }
                field(InvoicedPriceLCYTotal; PL[16])
                {
                    ApplicationArea = All;
                    Caption = 'Total';
                    Editable = false;
                    Style = Strong;
                    StyleExpr = true;
                    ToolTip = 'Specifies the total invoiced price of a project.';

                    trigger OnDrillDown()
                    var
                        IsHandled: Boolean;
                    begin
                        IsHandled := false;
                        OnBeforeOnDrillDownInvoicedPriceLCYTotal(Rec, IsHandled);
                        if not IsHandled then
                            ContratoCalcStatistics.ShowLedgEntry(0, false);
                    end;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetCurrRecord()
    begin
        Clear(ContratoCalcStatistics);
        ContratoCalcStatistics.ContratoCalculateCommonFilters(Rec);
        ContratoCalcStatistics.CalculateAmounts();
        ContratoCalcStatistics.GetLCYCostAmounts(CL);
        ContratoCalcStatistics.GetLCYPriceAmounts(PL);
    end;

    var
        ContratoCalcStatistics: Codeunit "Contrato Calculate Statistics";
        PlaceHolderLbl: Label 'Placeholder';
        CL: array[16] of Decimal;
        PL: array[16] of Decimal;

    local procedure ShowDetails()
    begin
        PAGE.Run(PAGE::"Contrato Card", Rec);
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeOnDrillDownBillablePriceLCY(var Contrato: Record Contrato; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeOnDrillDownBillablePriceLCYTotal(var Contrato: Record Contrato; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeOnDrillDownBillablePriceLCYGLAcc(var Contrato: Record Contrato; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeOnDrillDownBillablePriceLCYItem(var Contrato: Record Contrato; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeOnDrillDownInvoicedPriceLCYGLAcc(var Contrato: Record Contrato; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeOnDrillDownInvoicedPriceLCYTotal(var Contrato: Record Contrato; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeOnDrillDownInvoicedPriceLCYItem(var Contrato: Record Contrato; var IsHandled: Boolean);
    begin
    end;

    [IntegrationEvent(true, false)]
    local procedure OnBeforeOnDrillDownInvoicedPriceLCY(var Contrato: Record Contrato; var IsHandled: Boolean);
    begin
    end;
}
