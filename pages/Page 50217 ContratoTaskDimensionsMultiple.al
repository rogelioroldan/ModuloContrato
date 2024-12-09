page 50217 "ContratoTaskDimensionsMultiple"
{
    Caption = 'Project Task Dimensions Multiple';
    PageType = List;
    SourceTable = "Contrato Task Dimension";
    SourceTableTemporary = true;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Dimension Code"; Rec."Dimension Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for the dimension that the dimension value filter will be linked to. To select a dimension codes, which are set up in the Dimensions window, click the drop-down arrow in the field.';

                    trigger OnValidate()
                    begin
                        if (xRec."Dimension Code" <> '') and (xRec."Dimension Code" <> Rec."Dimension Code") then
                            Error(Text000, Rec.TableCaption);
                    end;
                }
                field("Dimension Value Code"; Rec."Dimension Value Code")
                {
                    ApplicationArea = Dimensions;
                    ToolTip = 'Specifies the code for the dimension value that the dimension value filter will be linked to. To select a value code, which are set up in the Dimensions window, choose the drop-down arrow in the field.';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        DimensionValueCodeOnFormat(Format(Rec."Dimension Value Code"));
    end;

    trigger OnDeleteRecord(): Boolean
    begin
        Rec."Multiple Selection Action" := Rec."Multiple Selection Action"::Delete;
        Rec.Modify();
        exit(false);
    end;

    trigger OnInit()
    begin
        CurrPage.LookupMode := true;
    end;

    trigger OnInsertRecord(BelowxRec: Boolean): Boolean
    begin
        Rec.SetRange("Dimension Code", Rec."Dimension Code");
        if not Rec.Find('-') and (Rec."Dimension Code" <> '') then begin
            Rec."Multiple Selection Action" := Rec."Multiple Selection Action"::Change;
            Rec.Insert();
        end;
        Rec.SetRange("Dimension Code");
        exit(false);
    end;

    trigger OnModifyRecord(): Boolean
    begin
        Rec."Multiple Selection Action" := Rec."Multiple Selection Action"::Change;
        Rec.Modify();
        exit(false);
    end;

    trigger OnOpenPage()
    begin
        GetDefaultDim();
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    begin
        if CloseAction = ACTION::LookupOK then
            LookupOKOnPush();
    end;

    var
        TempContratoTaskDim2: Record "Contrato Task Dimension" temporary;
        TempContratoTaskDim3: Record "Contrato Task Dimension" temporary;
        TempContratoTask: Record "Contrato Task" temporary;
        TotalRecNo: Integer;
        Text000: Label 'You cannot rename a %1.';
        Text001: Label '(Conflict)';

    local procedure SetCommonContratoTaskDim()
    var
        ContratoTaskDim: Record "Contrato Task Dimension";
    begin
        Rec.SetRange("Multiple Selection Action", Rec."Multiple Selection Action"::Delete);
        if Rec.Find('-') then
            repeat
                if TempContratoTaskDim3.Find('-') then
                    repeat
                        if ContratoTaskDim.Get(TempContratoTaskDim3."Contrato No.", TempContratoTaskDim3."Contrato Task No.", Rec."Dimension Code")
                        then
                            ContratoTaskDim.Delete(true);
                    until TempContratoTaskDim3.Next() = 0;
            until Rec.Next() = 0;
        Rec.SetRange("Multiple Selection Action", Rec."Multiple Selection Action"::Change);
        if Rec.Find('-') then
            repeat
                if TempContratoTaskDim3.Find('-') then
                    repeat
                        if ContratoTaskDim.Get(TempContratoTaskDim3."Contrato No.", TempContratoTaskDim3."Contrato Task No.", Rec."Dimension Code")
                        then begin
                            ContratoTaskDim."Dimension Code" := Rec."Dimension Code";
                            ContratoTaskDim."Dimension Value Code" := Rec."Dimension Value Code";
                            ContratoTaskDim.Modify(true);
                        end else begin
                            ContratoTaskDim.Init();
                            ContratoTaskDim."Contrato No." := TempContratoTaskDim3."Contrato No.";
                            ContratoTaskDim."Contrato Task No." := TempContratoTaskDim3."Contrato Task No.";
                            ContratoTaskDim."Dimension Code" := Rec."Dimension Code";
                            ContratoTaskDim."Dimension Value Code" := Rec."Dimension Value Code";
                            ContratoTaskDim.Insert(true);
                        end;
                    until TempContratoTaskDim3.Next() = 0;
            until Rec.Next() = 0;
    end;

    procedure SetMultiContratoTask(var ContratoTask: Record "Contrato Task")
    begin
        TempContratoTaskDim2.DeleteAll();
        TempContratoTask.DeleteAll();
        if ContratoTask.Find('-') then
            repeat
                CopyContratoTaskDimToContratoTaskDim(ContratoTask."Contrato No.", ContratoTask."Contrato Task No.");
                TempContratoTask.TransferFields(ContratoTask);
                TempContratoTask.Insert();
            until ContratoTask.Next() = 0;
    end;

    local procedure CopyContratoTaskDimToContratoTaskDim(ContratoNo: Code[20]; ContratoTaskNo: Code[20])
    var
        ContratoTaskDim: Record "Contrato Task Dimension";
    begin
        TotalRecNo := TotalRecNo + 1;
        TempContratoTaskDim3."Contrato No." := ContratoNo;
        TempContratoTaskDim3."Contrato Task No." := ContratoTaskNo;
        TempContratoTaskDim3.Insert();

        ContratoTaskDim.SetRange("Contrato No.", ContratoNo);
        ContratoTaskDim.SetRange("Contrato Task No.", ContratoTaskNo);
        if ContratoTaskDim.Find('-') then
            repeat
                TempContratoTaskDim2 := ContratoTaskDim;
                TempContratoTaskDim2.Insert();
            until ContratoTaskDim.Next() = 0;
    end;

    local procedure GetDefaultDim()
    var
        Dim: Record Dimension;
        RecNo: Integer;
    begin
        Rec.Reset();
        Rec.DeleteAll();
        if Dim.Find('-') then
            repeat
                RecNo := 0;
                TempContratoTaskDim2.SetRange("Dimension Code", Dim.Code);
                Rec.SetRange("Dimension Code", Dim.Code);
                if TempContratoTaskDim2.Find('-') then
                    repeat
                        if Rec.Find('-') then begin
                            if Rec."Dimension Value Code" <> TempContratoTaskDim2."Dimension Value Code" then
                                if (Rec."Multiple Selection Action" <> 10) and
                                   (Rec."Multiple Selection Action" <> 21)
                                then begin
                                    Rec."Multiple Selection Action" :=
                                      Rec."Multiple Selection Action" + 10;
                                    Rec."Dimension Value Code" := '';
                                end;
                            Rec.Modify();
                            RecNo := RecNo + 1;
                        end else begin
                            Rec := TempContratoTaskDim2;
                            Rec.Insert();
                            RecNo := RecNo + 1;
                        end;
                    until TempContratoTaskDim2.Next() = 0;

                if Rec.Find('-') and (RecNo <> TotalRecNo) then
                    if (Rec."Multiple Selection Action" <> 10) and
                       (Rec."Multiple Selection Action" <> 21)
                    then begin
                        Rec."Multiple Selection Action" :=
                          Rec."Multiple Selection Action" + 10;
                        Rec."Dimension Value Code" := '';
                        Rec.Modify();
                    end;
            until Dim.Next() = 0;

        Rec.Reset();
        Rec.SetCurrentKey("Dimension Code");
        Rec.SetFilter("Multiple Selection Action", '<>%1', Rec."Multiple Selection Action"::Delete)
    end;

    local procedure LookupOKOnPush()
    begin
        SetCommonContratoTaskDim();
    end;

    local procedure DimensionValueCodeOnFormat(Text: Text[1024])
    begin
        if Rec."Dimension Code" <> '' then
            if (Rec."Multiple Selection Action" = 10) or
               (Rec."Multiple Selection Action" = 21)
            then
                Text := Text001;
    end;
}

