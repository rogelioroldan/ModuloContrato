report 50224 "OpenPurchaseInvoicesbyContrato"
{
    DefaultLayout = RDLC;
    RDLCLayout = './Local/Contratos/Contrato/Reports/OpenPurchaseInvoicesbyContrato.rdlc';
    Caption = 'Open Purchase Invoices by Contrato';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem(Contrato; Contrato)
        {
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", Description, "Bill-to Customer No.", "Person Responsible";
            column(FORMAT_TODAY_0_4_; Format(Today, 0, 4))
            {
            }
            column(TIME; Time)
            {
            }
            column(CompanyInformation_Name; CompanyInformation.Name)
            {
            }
            column(USERID; UserId)
            {
            }
            column(Contrato_TABLECAPTION__________FilterString; Contrato.TableCaption + ': ' + FilterString)
            {
            }
            column(FilterString; FilterString)
            {
            }
            column(TABLECAPTION___________No__; TableCaption + ': ' + "No.")
            {
            }
            column(Contrato_Description; Description)
            {
            }
            column(Contrato_No_; "No.")
            {
            }
            column(Open_Purchase_Invoices_by_ContratoCaption; Open_Purchase_Invoices_by_ContratoCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Vendor_Ledger_Entry__Document_No__Caption; "Vendor Ledger Entry".FieldCaption("Document No."))
            {
            }
            column(Vendor_NameCaption; Vendor_NameCaptionLbl)
            {
            }
            column(Vendor_Ledger_Entry__Posting_Date_Caption; "Vendor Ledger Entry".FieldCaption("Posting Date"))
            {
            }
            column(Vendor_Ledger_Entry__Due_Date_Caption; "Vendor Ledger Entry".FieldCaption("Due Date"))
            {
            }
            column(Vendor_Ledger_Entry_AmountCaption; Vendor_Ledger_Entry_AmountCaptionLbl)
            {
            }
            column(Amount____Remaining_Amount_Caption; Amount____Remaining_Amount_CaptionLbl)
            {
            }
            column(Vendor_Ledger_Entry__Remaining_Amount_Caption; Vendor_Ledger_Entry__Remaining_Amount_CaptionLbl)
            {
            }
            column(Vendor_Ledger_Entry__Vendor_No__Caption; "Vendor Ledger Entry".FieldCaption("Vendor No."))
            {
            }
            column(Vendor_Ledger_Entry__Currency_Code_Caption; "Vendor Ledger Entry".FieldCaption("Currency Code"))
            {
            }
            dataitem("Purch. Inv. Line"; "Purch. Inv. Line")
            {
                DataItemLink = "Job No." = field("No.");
                DataItemTableView = sorting("Document No.", "Line No.");
                PrintOnlyIfDetail = true;
                column(Contrato_TABLECAPTION__________Contrato__No________Total_____; Contrato.TableCaption + ': ' + Contrato."No." + '  Total ($)')
                {
                }
                column(Vendor_Ledger_Entry___Amount__LCY__; "Vendor Ledger Entry"."Amount (LCY)")
                {
                }
                column(Vendor_Ledger_Entry___Amount__LCY______Vendor_Ledger_Entry___Remaining_Amt___LCY__; "Vendor Ledger Entry"."Amount (LCY)" - "Vendor Ledger Entry"."Remaining Amt. (LCY)")
                {
                }
                column(Vendor_Ledger_Entry___Remaining_Amt___LCY__; "Vendor Ledger Entry"."Remaining Amt. (LCY)")
                {
                }
                column(Purch__Inv__Line_Document_No_; "Document No.")
                {
                }
                column(Purch__Inv__Line_Line_No_; "Line No.")
                {
                }
                column(Purch__Inv__Line_Contrato_No_; "Job No.")
                {
                }
                dataitem("Vendor Ledger Entry"; "Vendor Ledger Entry")
                {
                    DataItemLink = "Document No." = field("Document No.");
                    DataItemTableView = sorting("Document No.", "Document Type", "Vendor No.") where("Document Type" = const(Invoice), Open = const(true));
                    column(Vendor_Ledger_Entry__Document_No__; "Document No.")
                    {
                    }
                    column(PurchInvoiceHeader__Pay_to_Name_; PurchInvoiceHeader."Pay-to Name")
                    {
                    }
                    column(Vendor_Ledger_Entry__Posting_Date_; "Posting Date")
                    {
                    }
                    column(Vendor_Ledger_Entry__Due_Date_; "Due Date")
                    {
                    }
                    column(Vendor_Ledger_Entry_Amount; Amount)
                    {
                    }
                    column(Amount____Remaining_Amount_; Amount - "Remaining Amount")
                    {
                    }
                    column(Vendor_Ledger_Entry__Remaining_Amount_; "Remaining Amount")
                    {
                    }
                    column(Vendor_Ledger_Entry__Vendor_No__; "Vendor No.")
                    {
                    }
                    column(Vendor_Ledger_Entry__Currency_Code_; "Currency Code")
                    {
                    }
                    column(Vendor_Ledger_Entry_Entry_No_; "Entry No.")
                    {
                    }

                    trigger OnAfterGetRecord()
                    begin
                        CalcFields("Amount (LCY)", "Remaining Amt. (LCY)");
                    end;

                    trigger OnPreDataItem()
                    begin
                        SetRange("Vendor No.", PurchInvoiceHeader."Pay-to Vendor No.");
                    end;
                }

                trigger OnAfterGetRecord()
                begin
                    SetRange("Document No.", "Document No.");
                    Find('+');
                    SetRange("Document No.");
                    PurchInvoiceHeader.Get("Document No.");
                end;

                trigger OnPreDataItem()
                begin
                    if not SetCurrentKey("Job No.", "Document No.") then begin
                        SetCurrentKey("Document No.");
                        if not AlreadyDisplayedMessage then begin
                            Message(Text000 + ' ' +
                              Text001,
                              TableName, FieldCaption("Job No."), FieldCaption("Document No."));
                            AlreadyDisplayedMessage := true;
                        end;
                    end;
                end;
            }
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
        }

        actions
        {
        }
    }

    labels
    {
    }

    trigger OnPreReport()
    begin
        CompanyInformation.Get();
        FilterString := Contrato.GetFilters();
    end;

    var
        CompanyInformation: Record "Company Information";
        PurchInvoiceHeader: Record "Purch. Inv. Header";
        FilterString: Text;
        AlreadyDisplayedMessage: Boolean;
        Text000: Label 'This report will run much faster next time if you add a key to';
        Text001: Label 'the %1 table (123) which starts with %2,%3';
        Open_Purchase_Invoices_by_ContratoCaptionLbl: Label 'Open Purchase Invoices by Contrato';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Vendor_NameCaptionLbl: Label 'Vendor Name';
        Vendor_Ledger_Entry_AmountCaptionLbl: Label 'Invoice Amount';
        Amount____Remaining_Amount_CaptionLbl: Label 'Payments or Adjustments';
        Vendor_Ledger_Entry__Remaining_Amount_CaptionLbl: Label 'Balance Due';
}

