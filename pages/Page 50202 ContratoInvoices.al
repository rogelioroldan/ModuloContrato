
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
                    ToolTip = 'Specifies the quantity transferred from the project planning line to the invoice or credit memo.';
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
                    ToolTip = 'Specifies a link to the project ledger entry that was created when the document was posted.';
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
                        JobCreateInvoice: Codeunit "Contrato Create-Invoice";
                    begin
                        JobCreateInvoice.OpenSalesInvoice(Rec);
                        JobCreateInvoice.FindInvoices(Rec, JobNo, JobTaskNo, JobPlanningLineNo, DetailLevel);
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
        JobCreateInvoice: Codeunit "Contrato Create-Invoice";
    begin
        JobCreateInvoice.FindInvoices(Rec, JobNo, JobTaskNo, JobPlanningLineNo, DetailLevel);
    end;

    var
        JobNo: Code[20];
        JobTaskNo: Code[20];
        JobPlanningLineNo: Integer;
        DetailLevel: Option All,"Per Contrato","Per Contrato Task","Per Contrato Planning Line";
        ShowDetails: Boolean;

    procedure SetPrJob(Contrato: Record Contrato)
    begin
        DetailLevel := DetailLevel::"Per Contrato";
        JobNo := Contrato."No.";
    end;

    procedure SetPrJobTask(JobTask: Record "Contrato Task")
    begin
        DetailLevel := DetailLevel::"Per Contrato Task";
        JobNo := JobTask."Contrato No.";
        JobTaskNo := JobTask."Contrato Task No.";
    end;

    procedure SetPrJobPlanningLine(JobPlanningLine: Record "Contrato Planning Line")
    begin
        DetailLevel := DetailLevel::"Per Contrato Planning Line";
        JobNo := JobPlanningLine."Contrato No.";
        JobTaskNo := JobPlanningLine."Contrato Task No.";
        JobPlanningLineNo := JobPlanningLine."Line No.";
    end;

    procedure SetShowDetails(NewShowDetails: Boolean)
    begin
        ShowDetails := NewShowDetails;
    end;
}