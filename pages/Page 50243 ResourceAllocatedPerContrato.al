page 50243 "ResourceAllocatedperContrato"
{
    Caption = 'Resource Allocated per Contrato';
    DataCaptionExpression = '';
    DeleteAllowed = false;
    InsertAllowed = false;
    LinksAllowed = false;
    PageType = Card;
    SaveValues = true;
    SourceTable = Contrato;

    layout
    {
        area(content)
        {
            group(General)
            {
                Caption = 'General';
                field(ResourceFilter; ResourceFilter)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Resource Filter';
                    Lookup = true;
                    LookupPageID = "Resource List";
                    TableRelation = Resource;
                    ToolTip = 'Specifies the resource that the allocations apply to.';
                }
                field(AmountType; AmountType)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Amount Type';
                    ToolTip = 'Specifies if the amount is for prices, costs, or profit values.';
                }
            }
            group("Matrix Options")
            {
                Caption = 'Matrix Options';
                field(PeriodType; PeriodType)
                {
                    ApplicationArea = Contratos;
                    Caption = 'View by';
                    ToolTip = 'Specifies by which period amounts are displayed.';

                    trigger OnValidate()
                    begin
                        DateControl();
                        SetMatrixColumns(Enum::"Matrix Page Step Type"::Initial);
                    end;
                }
                field(DateFilter; DateFilter)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Date Filter';
                    ToolTip = 'Specifies the dates that will be used to filter the amounts in the window.';

                    trigger OnValidate()
                    begin
                        DateControl();
                        SetMatrixColumns(Enum::"Matrix Page Step Type"::Initial);
                        CurrPage.Update();
                    end;
                }
                field(ColumnsSet; ColumnsSet)
                {
                    ApplicationArea = Contratos;
                    Caption = 'Column set';
                    Editable = false;
                    ToolTip = 'Specifies the range of values that are displayed in the matrix window, for example, the total period. To change the contents of the field, choose Next Set or Previous Set.';
                }
            }
        }
    }

    actions
    {
        area(processing)
        {
            action(ShowMatrix)
            {
                ApplicationArea = Contratos;
                Caption = 'Show Matrix';
                Image = ShowMatrix;
                ToolTip = 'Open the matrix window to see data according to the specified values.';

                trigger OnAction()
                var
                    HorizontalRecord: Record "Contrato Planning Line";
                    ResAllPerContratoFormWithMatrix: Page ResourceAllocperContratoMatrix;
                    IsHandled: Boolean;
                begin
                    IsHandled := false;
                    OnActionShowMatrix(ContratoRec, ResourceFilter, MatrixColumnCaptions, MatrixRecords, AmountType, IsHandled);
                    if IsHandled then
                        exit;

                    HorizontalRecord.SetRange("No.", ResourceFilter);
                    HorizontalRecord.SetRange(Type, HorizontalRecord.Type::Resource);
                    ContratoRec.SetRange("Resource Filter", ResourceFilter);
                    OnActionShowMatrixOnAfterSetContratoFilters(ContratoRec);
                    ResAllPerContratoFormWithMatrix.LoadMatrix(ContratoRec, HorizontalRecord, MatrixColumnCaptions, MatrixRecords, AmountType);
                    ResAllPerContratoFormWithMatrix.RunModal();
                end;
            }
            action("Previous Set")
            {
                ApplicationArea = Contratos;
                Caption = 'Previous Set';
                Image = PreviousSet;
                ToolTip = 'Go to the previous set of data.';

                trigger OnAction()
                begin
                    SetMatrixColumns(Enum::"Matrix Page Step Type"::Previous);
                end;
            }
            action("Next Set")
            {
                ApplicationArea = Contratos;
                Caption = 'Next Set';
                Image = NextSet;
                ToolTip = 'Go to the next set of data.';

                trigger OnAction()
                begin
                    SetMatrixColumns(Enum::"Matrix Page Step Type"::Next);
                end;
            }
        }
        area(Promoted)
        {
            group(Category_Process)
            {
                Caption = 'Process';

                actionref("Previous Set_Promoted"; "Previous Set")
                {
                }
                actionref(ShowMatrix_Promoted; ShowMatrix)
                {
                }
                actionref("Next Set_Promoted"; "Next Set")
                {
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        SetMatrixColumns(Enum::"Matrix Page Step Type"::Initial);
        if Rec.HasFilter then
            ResourceFilter := Rec.GetFilter("Resource Filter");
    end;

    var
        MatrixRecords: array[32] of Record Date;
        ResRec2: Record Resource;
        ContratoRec: Record Contrato;
        FilterTokens: Codeunit "Filter Tokens";
        DateFilter: Text;
        ResourceFilter: Text;
        PeriodType: Enum "Analysis Period Type";
        AmountType: Enum "Analysis Amount Type";
        PKFirstRecInCurrSet: Text[1024];
        MatrixColumnCaptions: array[32] of Text[100];
        ColumnsSet: Text[1024];
        CurrSetLength: Integer;

    local procedure DateControl()
    begin
        FilterTokens.MakeDateFilter(DateFilter);

        ResRec2.SetFilter("Date Filter", DateFilter);
        DateFilter := ResRec2.GetFilter("Date Filter");
    end;

    procedure SetMatrixColumns(StepType: Enum "Matrix Page Step Type")
    var
        MatrixMgt: Codeunit "Matrix Management";
    begin
        MatrixMgt.GeneratePeriodMatrixData(
            StepType.AsInteger(), 32, false, PeriodType, DateFilter, PKFirstRecInCurrSet, MatrixColumnCaptions,
            ColumnsSet, CurrSetLength, MatrixRecords);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnActionShowMatrix(var ContratoRec: Record Contrato; ResourceFilter: Text; MatrixColumnCaptions: array[32] of Text; MatrixRecords: array[32] of Record Date; AmountType: Enum "Analysis Amount Type"; var IsHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnActionShowMatrixOnAfterSetContratoFilters(var ContratoRec: Record Contrato)
    begin
    end;
}

