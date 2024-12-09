report 50222 "Contrato Register"
{
    AdditionalSearchTerms = 'Contrato Register';
    DefaultLayout = RDLC;
    RDLCLayout = './Contratos/Contrato/Reports/ContratoRegister.rdlc';
    ApplicationArea = Contratos;
    Caption = 'Contrato Register';
    UsageCategory = ReportsAndAnalysis;

    dataset
    {
        dataitem("Contrato Register"; "Contrato Register")
        {
            DataItemTableView = sorting("No.");
            PrintOnlyIfDetail = true;
            RequestFilterFields = "No.", "Creation Date", "Source Code", "Journal Batch Name";
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
            column(ContratoRegFilter; ContratoRegFilter)
            {
            }
            column(ContratoEntryFilter; ContratoEntryFilter)
            {
            }
            column(Contrato_Register__TABLECAPTION__________ContratoRegFilter; "Contrato Register".TableCaption + ': ' + ContratoRegFilter)
            {
            }
            column(Contrato_Ledger_Entry__TABLECAPTION__________ContratoEntryFilter; "Contrato Ledger Entry".TableCaption + ': ' + ContratoEntryFilter)
            {
            }
            column(Register_No______FORMAT__No___; 'Register No: ' + Format("No."))
            {
            }
            column(SourceCodeText; SourceCodeText)
            {
            }
            column(SourceCode_Description; SourceCode.Description)
            {
            }
            column(Contrato_Register___No__; "Contrato Register"."No.")
            {
            }
            column(Contrato_RegisterCaption; Contrato_RegisterCaptionLbl)
            {
            }
            column(CurrReport_PAGENOCaption; CurrReport_PAGENOCaptionLbl)
            {
            }
            column(Contrato_Ledger_Entry__Contrato_No__Caption; "Contrato Ledger Entry".FieldCaption("Contrato No."))
            {
            }
            column(Contrato_Ledger_Entry__Document_No__Caption; "Contrato Ledger Entry".FieldCaption("Document No."))
            {
            }
            column(Contrato_Ledger_Entry__Entry_Type_Caption; "Contrato Ledger Entry".FieldCaption("Entry Type"))
            {
            }
            column(Contrato_Ledger_Entry__Posting_Date_Caption; "Contrato Ledger Entry".FieldCaption("Posting Date"))
            {
            }
            column(Contrato_Ledger_Entry__Unit_of_Measure_Code_Caption; "Contrato Ledger Entry".FieldCaption("Unit of Measure Code"))
            {
            }
            column(Contrato_Ledger_Entry_TypeCaption; "Contrato Ledger Entry".FieldCaption(Type))
            {
            }
            column(Contrato_Ledger_Entry__No__Caption; "Contrato Ledger Entry".FieldCaption("No."))
            {
            }
            column(Contrato_Ledger_Entry_QuantityCaption; "Contrato Ledger Entry".FieldCaption(Quantity))
            {
            }
            column(Contrato_Ledger_Entry__Unit_Cost__LCY__Caption; "Contrato Ledger Entry".FieldCaption("Unit Cost (LCY)"))
            {
            }
            column(Contrato_Ledger_Entry__Total_Cost__LCY__Caption; "Contrato Ledger Entry".FieldCaption("Total Cost (LCY)"))
            {
            }
            column(Contrato_Ledger_Entry__Total_Price__LCY__Caption; "Contrato Ledger Entry".FieldCaption("Total Price (LCY)"))
            {
            }
            column(Contrato_Ledger_Entry__Unit_Price__LCY__Caption; "Contrato Ledger Entry".FieldCaption("Unit Price (LCY)"))
            {
            }
            dataitem("Contrato Ledger Entry"; "Contrato Ledger Entry")
            {
                DataItemTableView = sorting("Entry No.");
                RequestFilterFields = "Contrato No.", "Posting Date", "Document No.";
                column(Contrato_Ledger_Entry__Contrato_No__; "Contrato No.")
                {
                }
                column(Contrato_Ledger_Entry__Posting_Date_; "Posting Date")
                {
                }
                column(Contrato_Ledger_Entry__Document_No__; "Document No.")
                {
                }
                column(Contrato_Ledger_Entry__Entry_Type_; "Entry Type")
                {
                }
                column(Contrato_Ledger_Entry_Type; Type)
                {
                }
                column(Contrato_Ledger_Entry__No__; "No.")
                {
                }
                column(Contrato_Ledger_Entry_Quantity; Quantity)
                {
                    DecimalPlaces = 2 : 5;
                }
                column(Contrato_Ledger_Entry__Unit_of_Measure_Code_; "Unit of Measure Code")
                {
                }
                column(Contrato_Ledger_Entry__Unit_Cost__LCY__; "Unit Cost (LCY)")
                {
                }
                column(Contrato_Ledger_Entry__Total_Cost__LCY__; "Total Cost (LCY)")
                {
                }
                column(Contrato_Ledger_Entry__Unit_Price__LCY__; "Unit Price (LCY)")
                {
                }
                column(Contrato_Ledger_Entry__Total_Price__LCY__; "Total Price (LCY)")
                {
                }
                column(ContratoDescription; ContratoDescription)
                {
                }
                column(PrintContratoDescriptions; PrintContratoDescriptions)
                {
                }
                column(Contrato_Ledger_Entry___Entry_No__; "Contrato Ledger Entry"."Entry No.")
                {
                }
                column(Contrato_Register___No___Control43; "Contrato Register"."No.")
                {
                }
                column(Contrato_Register___To_Entry_No______Contrato_Register___From_Entry_No_____1; "Contrato Register"."To Entry No." - "Contrato Register"."From Entry No." + 1)
                {
                }
                column(Number_of_Entries_in_Register_No_Caption; Number_of_Entries_in_Register_No_CaptionLbl)
                {
                }

                trigger OnAfterGetRecord()
                begin
                    ContratoDescription := Description;
                    if ContratoDescription = '' then begin
                        if not Contrato.Get("Contrato No.") then
                            Contrato.Init();
                        ContratoDescription := Contrato.Description;
                    end;
                end;

                trigger OnPreDataItem()
                begin
                    SetRange("Entry No.", "Contrato Register"."From Entry No.", "Contrato Register"."To Entry No.")
                end;
            }

            trigger OnAfterGetRecord()
            begin
                if "Source Code" <> '' then begin
                    SourceCodeText := 'Source Code: ' + "Source Code";
                    if not SourceCode.Get("Source Code") then
                        SourceCode.Init();
                end else begin
                    Clear(SourceCodeText);
                    SourceCode.Init();
                end;
            end;
        }
    }

    requestpage
    {
        SaveValues = true;

        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Options';
                    field(PrintContratoDescriptions; PrintContratoDescriptions)
                    {
                        ApplicationArea = Contratos;
                        Caption = 'Print Contrato Descriptions';
                        ToolTip = 'Specifies that you want to include a section with the Contrato description based on the value in the Description field on the Contrato ledger entry.';
                    }
                }
            }
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
        ContratoRegFilter := "Contrato Register".GetFilters();
        ContratoEntryFilter := "Contrato Ledger Entry".GetFilters();
        CompanyInformation.Get();
    end;

    var
        Contrato: Record Contrato;
        CompanyInformation: Record "Company Information";
        SourceCode: Record "Source Code";
        PrintContratoDescriptions: Boolean;
        ContratoRegFilter: Text;
        ContratoEntryFilter: Text;
        ContratoDescription: Text[100];
        SourceCodeText: Text[50];
        Contrato_RegisterCaptionLbl: Label 'Contrato Register';
        CurrReport_PAGENOCaptionLbl: Label 'Page';
        Number_of_Entries_in_Register_No_CaptionLbl: Label 'Number of Entries in Register No.';
}

