
page 50202 "Contrato Invoices"
{
    Caption = 'Contrato Invoices';
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = List;
    RefreshOnActivate = true;
    SourceTable = "Contrato Planning Line Invoice";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field("Document Type"; Rec."Document Type")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the information about the type of document. There are four options:';
                }
                field("Document No."; Rec."Document No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the number associated with the document. For example, if you have created an invoice, the field Specifies the invoice number.';
                }
                field("Line No."; Rec."Line No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the line number that is linked to the document. Numbers are created sequentially.';
                    Visible = ShowDetails;
                }
                field("Quantity Transferred"; Rec."Quantity Transferred")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the quantity transferred from the contrato planning line to the invoice or credit memo.';
                }
                field("Transferred Date"; Rec."Transferred Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date on which the invoice or credit document was created. The date is set to the posting date you specified when you created the invoice or credit memo.';
                    Visible = ShowDetails;
                }
                field("Invoiced Date"; Rec."Invoiced Date")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the date on which the invoice or credit memo was posted.';
                    Visible = ShowDetails;
                }
                field("Invoiced Amount (LCY)"; Rec."Invoiced Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount (LCY) that was posted from the invoice or credit memo. The amount is calculated based on Quantity, Line Discount %, and Unit Price.';
                }
                field("Invoiced Cost Amount (LCY)"; Rec."Invoiced Cost Amount (LCY)")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the amount of the unit costs that has been posted from the invoice or credit memo. The amount is calculated based on Quantity, Unit Cost, and Line Discount %.';
                }
                field("Contrato Ledger Entry No."; Rec."Contrato Ledger Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies a link to the contrato ledger entry that was created when the document was posted.';
                    Visible = ShowDetails;
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
                action(OpenSalesInvoiceCreditMemo)
                {
                    ApplicationArea = All;
                    Caption = 'Open Sales Invoice/Credit Memo';
                    Ellipsis = true;
                    Image = GetSourceDoc;
                    ToolTip = 'Open the sales invoice or sales credit memo for the selected line.';

                    trigger OnAction()
                    var
                        ContratoCreateInvoice: Codeunit "Contrato Create-Invoice";
                    begin
                        ContratoCreateInvoice.OpenSalesInvoice(Rec);
                        ContratoCreateInvoice.FindInvoices(Rec, ContratoNo, ContratoTaskNo, ContratoPlanningLineNo, DetailLevel);
                        if Rec.Get(Rec."Contrato No.", Rec."Contrato Task No.", Rec."Contrato Planning Line No.", Rec."Document Type", Rec."Document No.", Rec."Line No.") then;
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref(OpenSalesInvoiceCreditMemo_Promoted; OpenSalesInvoiceCreditMemo)
                {
                }
            }
        }
    }

    trigger OnInit()
    begin
        ShowDetails := true;
    end;

    trigger OnOpenPage()
    var
        ContratoCreateInvoice: Codeunit "Contrato Create-Invoice";
    begin
        ContratoCreateInvoice.FindInvoices(Rec, ContratoNo, ContratoTaskNo, ContratoPlanningLineNo, DetailLevel);
    end;

    var
        ContratoNo: Code[20];
        ContratoTaskNo: Code[20];
        ContratoPlanningLineNo: Integer;
        DetailLevel: Option All,"Per Contrato","Per Contrato Task","Per Contrato Planning Line";
        ShowDetails: Boolean;

    procedure SetPrContrato(Contrato: Record Contrato)
    begin
        DetailLevel := DetailLevel::"Per Contrato";
        ContratoNo := Contrato."No.";
    end;

    procedure SetPrContratoTask(ContratoTask: Record "Contrato Task")
    begin
        DetailLevel := DetailLevel::"Per Contrato Task";
        ContratoNo := ContratoTask."Contrato No.";
        ContratoTaskNo := ContratoTask."Contrato Task No.";
    end;

    procedure SetPrContratoPlanningLine(ContratoPlanningLine: Record "Contrato Planning Line")
    begin
        DetailLevel := DetailLevel::"Per Contrato Planning Line";
        ContratoNo := ContratoPlanningLine."Contrato No.";
        ContratoTaskNo := ContratoPlanningLine."Contrato Task No.";
        ContratoPlanningLineNo := ContratoPlanningLine."Line No.";
    end;

    procedure SetShowDetails(NewShowDetails: Boolean)
    begin
        ShowDetails := NewShowDetails;
    end;
}